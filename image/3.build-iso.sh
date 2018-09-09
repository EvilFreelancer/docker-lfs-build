#!/bin/bash -x 

# Change folder to root of image
cd /image

IMAGE_ISO=/image/lfs.iso
rm -v $IMAGE_ISO

echo "> Building bootable iso.."

mv -v lfs.bz2 isolinux/

# build iso
genisoimage -o $IMAGE_ISO                \
            -b isolinux/isolinux.bin     \
            -c isolinux/boot.cat         \
            -no-emul-boot                \
            -boot-load-size 4            \
            -boot-info-table $LFS/image/

echo "Image is created: $IMAGE_ISO"
