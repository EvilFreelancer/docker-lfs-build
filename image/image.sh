#!/bin/bash -x

echo ">>> Start building bootable image.."

cd /image
mkdir isolinux

sh /image/1.configure-syslinux.sh
sh /image/2.create-ramdisk.sh
sh /image/3.build-iso.sh

rm -rf isolinux
