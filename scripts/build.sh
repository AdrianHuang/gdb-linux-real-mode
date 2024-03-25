#!/bin/bash

LSPCI_IDS_URL=https://pci-ids.ucw.cz/v2.2/pci.ids
LSPCI_IDS_PATH=/usr/share/misc
LSPCI_IDS=pci.ids

source `find ./ -name config.sh | head -n1`

build_sample_code() {
	cd $SAMPLE_CODE
	make
}

get_lspci_ids() {
	if [ ! -d $INITRAMFS_OUT/$LSPCI_IDS_PATH ]; then
		mkdir -pv $INITRAMFS_OUT/$LSPCI_IDS_PATH
	fi

	if [ ! -f $INITRAMFS_OUT/$LSPCI_IDS_PATH/$LSPCI_IDS ]; then
		wget -P $INITRAMFS_OUT/$LSPCI_IDS_PATH $LSPCI_IDS_URL
	fi
}

copy_sample_code() {
	local exec_files=`find ${SAMPLE_CODE} -type f -executable -print`

	mkdir -pv $INITRAMFS_OUT/sample-code

	for i in $exec_files; do
		cp $i $INITRAMFS_OUT/sample-code/
	done

	get_lspci_ids
}

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

	mkdir -pv $INITRAMFS_OUT
	cd $INITRAMFS_OUT
	mkdir -pv {bin,dev,sbin,etc,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root}
	cp -av $OUT/obj/busybox/_install/* $INITRAMFS_OUT
	sudo cp -av /dev/{null,console,tty,sda1} $INITRAMFS_OUT/dev/

	build_sample_code
	copy_sample_code

	# This is a quite tricky way to run 'tee' with EOF in a bash function.
        # The file content 'INITRAMFS_OUT/init' cannot have the
	# indentation for the utility command 'tee file << EOF'
	tee $INITRAMFS_OUT/init << EOF
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
exec /bin/sh
EOF

	chmod +x $INITRAMFS_OUT/init

	cd $INITRAMFS_OUT
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

	cp $KERNEL_CONFIG $KERNEL_OBJ/.config

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
