#!/bin/bash

source `find ./ -name config.sh | head -n1`

qemu_bin=qemu-system-x86_64

${qemu_bin} -nographic -smp 4 -m 2047M \
	-kernel $KERNEL_OBJ/arch/x86/boot/bzImage \
	-initrd $INITRAMFS_IGZ \
	-append "earlyprintk=serial,ttyS0 console=ttyS0 loglevel=8 nokaslr" \
	-s -S
