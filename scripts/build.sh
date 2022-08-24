#!/bin/bash

source `find ./ -name config.sh | head -n1`

build_busybox() {
	cd $SRC

	if [ ! -d $SRC/busybox-${BUSYBOX_VER} ]; then
		curl https://busybox.net/downloads/busybox-${BUSYBOX_VER}.tar.bz2 | tar jxf -
	fi

	cd $SRC/busybox-${BUSYBOX_VER}

	mkdir -pv $OUT/obj/busybox

	make O=$OUT/obj/busybox defconfig

	cp $ROOT/conf/busybox.config $OUT/obj/busybox/.config

	cd $OUT/obj/busybox
	make -j $(nproc)

	if [ $? != 0 ]; then
		echo "Failed to compile busybox"
		exit 1
	fi

	make install

	mkdir -pv $OUT/initramfs/busybox
	cd $OUT/initramfs/busybox
	mkdir -pv {bin,dev,sbin,etc,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root}
	cp -av $OUT/obj/busybox/_install/* $OUT/initramfs/busybox
	sudo cp -av /dev/{null,console,tty,sda1} $OUT/initramfs/busybox/dev/

	mkdir -pv $OUT/initramfs/busybox
	cd $OUT/initramfs/busybox
	mkdir -pv {bin,dev,sbin,etc,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root}
	cp -av $OUT/obj/busybox/_install/* $OUT/initramfs/busybox
	sudo cp -av /dev/{null,console,tty,sda1} $OUT/initramfs/busybox/dev/

	# This is a quite tricky way to run 'tee' with EOF in a bash function.
        # The file content 'OUT/initramfs/busybox/init' cannot have the
	# indentation for the utility command 'tee file << EOF'
	tee $OUT/initramfs/busybox/init << EOF
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
exec /bin/sh
EOF

	chmod +x $OUT/initramfs/busybox/init

	cd $OUT/initramfs/busybox
	find . | cpio -H newc -o > ../initramfs.cpio
	cd ..
	cat initramfs.cpio | gzip > $INITRAMFS_IGZ
}

build_kernel() { 
	cd $SRC

	if [ ! -d $KERNEL_FOLDER ]; then
		curl $KERNEL_LINK | tar xJf -
	fi

	cd $KERNEL_FOLDER

	mkdir -p $KERNEL_OBJ

	cp $ROOT/conf/kernel.config $KERNEL_OBJ/.config

	make O=$KERNEL_OBJ olddefconfig
	make O=$KERNEL_OBJ KCFLAGS=-ggdb3 -j $(nproc)
}


mkdir -p $SRC

if [ ! -f $INITRAMFS_IGZ ]; then
	build_busybox
fi

if [ ! -d $KERNEL_OBJ ]; then
	build_kernel
fi


echo "Done"
