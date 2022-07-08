#!/bin/bash

source `find ./ -name config.sh | head -n1`

qemu_bin=/usr/libexec/qemu-kvm

${qemu_bin} -nographic -smp cores=8 -cpu host -m 1G \
	-kernel $KERNEL_OBJ/arch/x86/boot/bzImage \
	-initrd $INITRAMFS_IGZ \
	-append "earlyprintk=serial,ttyS0 console=ttyS0 loglevel=8 nokaslr" \
	-chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-user1,debug=9 \
	-netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce \
	-device virtio-net-pci,mac=00:00:00:00:00:01,netdev=mynet1 \
	-object memory-backend-file,id=mem,size=1G,mem-path=/dev/hugepages,share=on \
	-numa node,memdev=mem -mem-prealloc \
	-boot c -enable-kvm -no-reboot -net none \
#	-s -S
