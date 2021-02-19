#!/bin/bash

source `find ./ -name config.sh | head -n1`

# Since we target at debugging real-mode (32 bit), we need to use
# the tool 'qemu-system-i386' instead of qemu-system-x86_64
# If you want to run x86_64 kernel image to boot into shell prompt,
# please use the tool 'qemu-system-x86_64'
qemu_bin=qemu-system-i386

${qemu_bin} -nographic -smp 4 -m 2047M \
	-kernel $KERNEL_OBJ/arch/x86/boot/bzImage \
	-initrd $INITRAMFS_IGZ \
	-append "earlyprintk=serial,ttyS0 console=ttyS0 loglevel=8 nokaslr" \
	-s -S
