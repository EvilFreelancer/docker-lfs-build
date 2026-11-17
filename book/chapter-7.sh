#!/bin/bash -x

set -e
set -o pipefail

echo ">>> Chapter 7"

# Keep the password out of xtrace, process arguments and child environments.
set +x
export -n LFS_ROOT_PASSWORD
printf '%s' "${LFS_ROOT_PASSWORD-}" | chroot "$LFS" /usr/bin/env -i \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/bash /book/chapter-7/7.x-configure-root-password.sh
unset LFS_ROOT_PASSWORD
set -x

# enter and continue in chroot environment with usr
chroot "$LFS" /usr/bin/env -i                   \
  HOME=/root TERM="$TERM" PS1='\u:\w\$ '        \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin            \
  LFS="$LFS" LC_ALL="$LC_ALL"                   \
  LFS_TGT="$LFS_TGT" MAKEFLAGS="$MAKEFLAGS"     \
  LFS_TEST="$LFS_TEST" LFS_DOCS="$LFS_DOCS"     \
  JOB_COUNT="$JOB_COUNT"                        \
  /bin/bash --login                             \
  -c "sh /book/chapter-7-chroot.sh"
