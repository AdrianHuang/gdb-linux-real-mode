#!/bin/bash

source `find ./ -name config.sh | head -n1`

GDB_FILES_FOLDER=$ROOT/gdb-files
GDB_LINUX_CFG=$GDB_FILES_FOLDER/gdb-linux-kernel-real-mode.txt
SETUP_ELF=$OUT/obj/linux/arch/x86/boot/setup.elf
SETUP_ELF_BASE=0x10000

generate_gdb_cfg() {
	local elf_sections=(".bstext" ".bsdata" ".header" ".entrytext" ".inittext" ".initdata" ".text32" ".bss" ".data")
	local sections_param=""

	text_section_addr=`readelf -S $SETUP_ELF  | grep -w .text | awk '{print $5}'`
	text_section_addr=`printf "0x%x" $((16#${text_section_addr} + $SETUP_ELF_BASE))`
	sections_param=$text_section_addr

	for((i=0;i<${#elf_sections[@]};i++)); do
		section_info=`readelf -S $SETUP_ELF  | grep -w ${elf_sections[$i]}`
		section_nr=`echo $section_info | awk -F '[][]' '{print $2}'`
		column=`([ $section_nr -le 9 ] && echo "5" ) || echo "4"`

		str="echo $section_info | awk '{print \$$column}'"
		section_addr=`eval $str`
		section_addr=`printf "0x%x" $((16#${section_addr} + $SETUP_ELF_BASE))`
		sections_param="$sections_param -s ${elf_sections[$i]} ${section_addr}"
	done

	# The kernel setup code (real-mode code) is placed at the second
	# sector of the kernel setup setup image (setup.bin). So, we need
	# to add the offset 0x200 to SETUP_ELF_BASE. Please refer to
	# the kernel documentation "Documentation/x86/boot.rst".
	setup_code_base_addr=`printf "0x%x" $((${SETUP_ELF_BASE} + 0x200))`

	# This is a quite tricky way to run 'tee' with EOF in a bash function.
        # The file content 'GDB_LINUX_CFG' cannot have the indentation for
	# the utility command 'tee file << EOF'
	tee $GDB_LINUX_CFG << EOF
# debug real-mode code of Linux kernel
add-symbol-file $SETUP_ELF $sections_param
target remote :1234
#b start_of_setup
b *$setup_code_base_addr
c
EOF
}

if [ ! -f $GDB_LINUX_CFG ]; then
	generate_gdb_cfg
fi

cd $GDB_FILES_FOLDER
gdb -ix $GDB_FILES_FOLDER/gdb-init-real-mode.txt -ix $GDB_LINUX_CFG
