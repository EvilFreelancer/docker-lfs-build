#!/bin/bash -x

echo ">>> Chapter 9"

# enter and continue in chroot environment with usr
chroot "$LFS" /usr/bin/env -i                   \
  HOME=/root TERM="$TERM" PS1='\u:\w\$ '        \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin            \
  LFS="$LFS" LC_ALL="$LC_ALL"                   \
  LFS_TGT="$LFS_TGT" MAKEFLAGS="$MAKEFLAGS"     \
  LFS_TEST="$LFS_TEST" LFS_DOCS="$LFS_DOCS"     \
  JOB_COUNT="$JOB_COUNT"                        \
  /bin/bash --login                             \
  -c "sh /book/chapter-9-chroot.sh"

# cleanup
sh /book/chapter-9/9.x-cleanup.sh
