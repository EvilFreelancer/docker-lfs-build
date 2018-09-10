#!/bin/bash -x 

# Change folder to root of image
cd /image

rm -v $IMAGE_ISO

echo "> Building bootable iso.."

cp -v $IMAGE_BZ2 isolinux/

# build iso
genisoimage -o $IMAGE_ISO                \
            -b isolinux/isolinux.bin     \
            -c isolinux/boot.cat         \
            -no-emul-boot                \
            -boot-load-size 4            \
            -boot-info-table $LFS/image/

echo "Image is created: $IMAGE_ISO"
