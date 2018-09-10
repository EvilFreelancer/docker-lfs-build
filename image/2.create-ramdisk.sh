#!/bin/bash -x

# Change folder to root of image
cd /image

echo "> Creating ramdisk..."

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
cp -dpR $(ls -A | grep -Ev "sources|tools|book|image|dist") $LOOP_DIR
popd

# show statistics
df $LOOP_DIR

echo "Compressing system ramdisk image.."
bzip2 -c $IMAGE_RAM > $IMAGE_BZ2

# Cleanup
umount $LOOP_DIR
losetup -d $LOOP
rm -rf $LOOP_DIR
