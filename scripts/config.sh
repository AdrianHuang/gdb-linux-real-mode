KERNEL_VER=6
KERNEL_PATCHLEVEL=3
KERNEL_LINK=https://mirrors.edge.kernel.org/pub/linux/kernel/v${KERNEL_VER}.x/linux-${KERNEL_VER}.${KERNEL_PATCHLEVEL}.tar.xz

ROOT=$PWD
SRC=$ROOT/src
OUT=$ROOT/out
SAMPLE_CODE=$ROOT/sample-code

BUSYBOX_VER=1.32.1
INITRAMFS_IGZ=$OUT/obj/initramfs.igz

KERNEL_FOLDER=$SRC/linux-${KERNEL_VER}.${KERNEL_PATCHLEVEL}
KERNEL_OBJ=$OUT/obj/linux
KERNEL_CONFIG=$ROOT/conf/kernel-${KERNEL_VER}.${KERNEL_PATCHLEVEL}.config
