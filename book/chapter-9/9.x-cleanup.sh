#!/bin/bash
set -e
echo "Cleanup.."

# Then unmount the virtual file systems:
umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

# Unmount the LFS file system itself:
umount -v $LFS
