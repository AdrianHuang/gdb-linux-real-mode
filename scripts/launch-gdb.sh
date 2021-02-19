#!/bin/bash

source `find ./ -name config.sh | head -n1`

GDB_FILES_FOLDER=$ROOT/gdb-files
GDB_LINUX_CFG=$GDB_FILES_FOLDER/gdb-linux-kernel-real-mode.txt
SETUP_ELF=$OUT/obj/linux/arch/x86/boot/setup.elf
SETUP_ELF_BASE=0x10000

generate_gdb_cfg() {
	elf_sections=(".bstext" ".bsdata" ".header" ".entrytext")
	elf_sections_addr=(0, 0, 0, 0)

	for((i=0;i<${#elf_sections[@]};i++)); do
		elf_sections_addr[$i]=`readelf -S $SETUP_ELF  | grep -w ${elf_sections[$i]} | awk '{print $5}'`
		elf_sections_addr[$i]=`printf "0x%x\n" $((16#${elf_sections_addr[$i]} + $SETUP_ELF_BASE))`
	done

	text_section_addr=`readelf -S $SETUP_ELF  | grep -w .text | awk '{print $5}'`
	text_section_addr=`printf "0x%x" $((16#${text_section_addr} + $SETUP_ELF_BASE))`

	# This is a quite tricky way to run 'tee' with EOF in a bash function.
        # The file content 'GDB_LINUX_CFG' cannot have the indentation for
	# the utility command 'tee file << EOF'
	tee $GDB_LINUX_CFG << EOF
# debug real-mode code of Linux kernel
add-symbol-file $SETUP_ELF 0x103f7 \\
        -s .bstext ${elf_sections_addr[0]} \\
	-s .bsdata ${elf_sections_addr[1]} \\
	-s .header ${elf_sections_addr[2]} \\
	-s .entrytext ${elf_sections_addr[3]}
target remote :1234
b start_of_setup
c
EOF
}

if [ ! -f $GDB_LINUX_CFG ]; then
	generate_gdb_cfg
fi

cd $GDB_FILES_FOLDER
gdb -ix $GDB_FILES_FOLDER/gdb-init-real-mode.txt -ix $GDB_LINUX_CFG
