#!/bin/bash

SCRIPT_FILDER=$(dirname $(readlink -f "$0"))
ROOT=$(dirname $SCRIPT_FILDER)

source `find $SCRIPT_FILDER -name config.sh | head -n1`

GDB_FILES_FOLDER=$ROOT/gdb-files
GDB_LINUX_CFG=$GDB_FILES_FOLDER/gdb-linux-kernel-real-mode.txt
GDB_SCRIPT=$KERNEL_FOLDER/scripts/gdb/vmlinux-gdb.py
HOME_GDB_INIT=~/.gdbinit

# Kernel setup code
SETUP_ELF=$OUT/obj/linux/arch/x86/boot/setup.elf
SETUP_ELF_BASE=0x10000
SETUP_ELF_SECTIONS=(".bstext" ".header" ".entrytext" ".inittext" ".initdata" ".text32" ".bss" ".data")

# Compressed vmlinux
COMPRESSED_VMLINUX_ELF=$OUT/obj/linux/arch/x86/boot/compressed/vmlinux
COMPRESSED_VMLINUX_ELF_BASE=0x100000
COMPRESSED_VMLINUX_ELF_SECTIONS=(".head.text" ".data" ".bss" ".pgtable")

# Decompressed vmlinux
DECOMPRESSED_VMLINUX_ELF=$OUT/obj/linux/vmlinux

parse_elf() {
	# $1: ELF file path
	# $2: ELF base address
	# $3: ELF sections
	local path=$1
	local base_addr=$2
	local -n sections=$3
	local sections_param=""

	text_section_addr=`readelf -S $path | grep -w .text | awk '{print $5}'`
	text_section_addr=`printf "0x%x" $((16#${text_section_addr} + $base_addr))`
	sections_param=$text_section_addr

	for((i=0;i<${#sections[@]};i++)); do
		section_info=`readelf -S $path | grep -w ${sections[$i]}`
		section_nr=`echo $section_info | awk -F '[][]' '{print $2}'`
		column=`([ $section_nr -le 9 ] && echo "5" ) || echo "4"`

		str="echo $section_info | awk '{print \$$column}'"
		section_addr=`eval $str`
		section_addr=`printf "0x%x" $((16#${section_addr} + $base_addr))`
		sections_param="$sections_param -s ${sections[$i]} ${section_addr}"
	done
	echo "add-symbol-file $path $sections_param"
}

generate_gdb_cfg() {
	# The kernel setup code (real-mode code) is placed at the second
	# sector of the kernel setup setup image (setup.bin). So, we need
	# to add the offset 0x200 to SETUP_ELF_BASE. Please refer to
	# the kernel documentation "Documentation/x86/boot.rst".
	setup_code_base_addr=`printf "0x%x" $((${SETUP_ELF_BASE} + 0x200))`

	# This is a quite tricky way to run 'tee' with EOF in a bash function.
        # The file content 'GDB_LINUX_CFG' cannot have the indentation for
	# the utility command 'tee file << EOF'
	tee $GDB_LINUX_CFG << EOF
# debug info about real-mode code of Linux kernel
#$(parse_elf $SETUP_ELF $SETUP_ELF_BASE SETUP_ELF_SECTIONS)

# debug info about compressed vmlinux
$(parse_elf $COMPRESSED_VMLINUX_ELF $COMPRESSED_VMLINUX_ELF_BASE COMPRESSED_VMLINUX_ELF_SECTIONS)
target remote :1234

# Uncomment the following line if you want to debug the decompressed vmlinux
add-symbol-file $DECOMPRESSED_VMLINUX_ELF

set print pretty on

# start_of_setup is the entry point in .entrytext section of setup.elf
#b start_of_setup

# startup_32 is the entry point in compressed vmlinux
#b startup_32

#b *$setup_code_base_addr

b pci_write_msg_msix

c
EOF
}

check_gdb_script() {
	if [ ! -f $HOME_GDB_INIT ]; then
		echo "add-auto-load-safe-path $GDB_SCRIPT" > $HOME_GDB_INIT
	else
		line_exist=$(grep $GDB_SCRIPT $HOME_GDB_INIT)
		if [ -z "$line_exist" ]; then
			echo "add-auto-load-safe-path $GDB_SCRIPT" >> $HOME_GDB_INIT
		fi
	fi
}

if [ ! -f $GDB_LINUX_CFG ]; then
	generate_gdb_cfg
fi

check_gdb_script

cd $GDB_FILES_FOLDER
gdb -ix $GDB_FILES_FOLDER/gdb-init-real-mode.txt -ix $GDB_LINUX_CFG
