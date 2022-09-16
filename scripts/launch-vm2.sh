#!/bin/bash

source `find ./ -name config.sh | head -n1`

qemu_bin=/usr/libexec/qemu-kvm

${qemu_bin} -nographic -smp cores=8 -cpu host -m 1G \
	-kernel $KERNEL_OBJ/arch/x86/boot/bzImage \
	-initrd $INITRAMFS_IGZ \
	-append "earlyprintk=serial,ttyS0 console=ttyS0 loglevel=8 nokaslr" \
	-chardev socket,id=char2,path=/tmp/dpdkvhostclient1,server=on \
	-netdev type=vhost-user,id=mynet2,chardev=char2,vhostforce=on \
	-device virtio-net-pci,mac=00:00:00:00:00:02,netdev=mynet2 \
	-object memory-backend-file,id=mem,size=1G,mem-path=/dev/hugepages,share=on \
	-numa node,memdev=mem -mem-prealloc \
	-boot c -enable-kvm -no-reboot -net none \
#	-s -S
