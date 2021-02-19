KERNEL_VER=5
KERNEL_PATCHLEVEL=11
KERNEL_LINK=https://mirrors.edge.kernel.org/pub/linux/kernel/v${KERNEL_VER}.x/linux-${KERNEL_VER}.${KERNEL_PATCHLEVEL}.tar.xz

ROOT=$PWD
SRC=$ROOT/src
OUT=$ROOT/out

BUSYBOX_VER=1.32.1
INITRAMFS_IGZ=$OUT/obj/initramfs.igz

KERNEL_FOLDER=$SRC/linux-${KERNEL_VER}.${KERNEL_PATCHLEVEL}
KERNEL_OBJ=$OUT/obj/linux
