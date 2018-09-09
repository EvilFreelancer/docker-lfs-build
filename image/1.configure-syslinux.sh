#!/bin/bash -x

echo "> Configuring syslinux.."

mkdir -p /image/isolinux

# extract syslinux
tar -xf /sources/syslinux-*.tar.xz -C /tmp/
mv /tmp/syslinux-* /tmp/syslinux

# copy needed syslinux binaries
cp -v /tmp/syslinux/bios/core/isolinux.bin /image/isolinux/isolinux.bin
cp -v /tmp/syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 /image/isolinux/ldlinux.c32

# copy kernel to isolinux folder
cp $LFS/boot/vmlinuz-* /image/isolinux/vmlinuz

# cleanup
rm -rf /tmp/syslinux

cat > /image/isolinux/isolinux.cfg << "EOF"
PROMT 0

DEFAULT bz2

LABEL bz2
    MENU LABEL Bz2 Image of RAM disk
    KERNEL vmlinuz
    APPEND initrd=lfs.bz2 root=/dev/ram0 rw 3
EOF
