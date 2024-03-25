#!/bin/bash

source `find ./ -name config.sh | head -n1`

qemu_bin=qemu-system-x86_64

${qemu_bin} -nographic -smp cores=4,sockets=2 -cpu Nehalem -m 16G \
	-object memory-backend-ram,id=mem0,size=8G \
	-object memory-backend-ram,id=mem1,size=8G \
        -numa node,memdev=mem0,cpus=0-3,nodeid=0 \
        -numa node,memdev=mem1,cpus=4-7,nodeid=1 \
	-device megasas,id=scsi0 \
	-kernel $KERNEL_OBJ/arch/x86/boot/bzImage \
	-initrd $INITRAMFS_IGZ \
	-append "earlyprintk=serial,ttyS0 console=ttyS0 loglevel=8 nokaslr norandmaps" \
	-s -S
