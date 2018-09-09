#!/bin/bash -x

# Change folder to root of image
cd /image

echo "> Creating ramdisk..."

export IMAGE_RAM=/image/lfs.ram
export IMAGE_BZ2=/image/lfs.bz2
export IMAGE_ISO=/image/lfs.iso
export IMAGE_HDD=/image/lfs.hdd
export LOOP=/dev/loop10
export LOOP_DIR=/image/loop
export IMAGE_SIZE=1000000

# Create yet another loop device if not exist
[ -e $LOOP ] || mknod $LOOP b 7 0

# create ramdisk file of IMAGE_SIZE
dd if=/dev/zero of=$IMAGE_RAM bs=1k count=$IMAGE_SIZE

# plug off any virtual fs from loop device
losetup -d $LOOP

# associate it with ${LOOP}
losetup $LOOP $IMAGE_RAM

# make an ext2 filesystem
mkfs.ext4 -q -m 0 $LOOP $IMAGE_SIZE

# ensure loop2 directory
[ -d $LOOP_DIR ] || mkdir -pv $LOOP_DIR

# mount it
mount $LOOP $LOOP_DIR
rm -rf $LOOP_DIR/lost+found

# copy LFS system without build artifacts
pushd $INITRD_TREE
cp -dpR $(ls -A | grep -Ev "sources|tools|book|image") $LOOP_DIR
popd

# show statistics
df $LOOP_DIR

echo "Compressing system ramdisk image.."
bzip2 -c $IMAGE_RAM > $IMAGE_BZ2

# Cleanup
umount $LOOP_DIR
losetup -d $LOOP
rm -rf $LOOP_DIR
rm -rf $IMAGE_RAM
