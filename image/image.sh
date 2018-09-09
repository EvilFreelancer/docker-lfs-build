#!/bin/bash -x

echo ">>> Start building bootable image.."

# Change folder to root of image
cd /image

sh /image/1.configure-syslinux.sh
sh /image/2.create-ramdisk.sh
sh /image/3.build-iso.sh

rm -rf /image/isolinux
