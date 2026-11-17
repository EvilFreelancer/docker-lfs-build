#!/bin/bash -x

# prepare to build
env -u LFS_ROOT_PASSWORD /book/chapter-3.sh

# execute rest as root
exec sudo -E -u root /bin/sh - <<'EOF'
# Only Chapter 7 needs the password in its environment.
export -n LFS_ROOT_PASSWORD

#  change ownership
chown -R root:root $LFS/tools

# prevent "bad interpreter: Text file busy"
sync

# continue
/book/chapter-5.sh
/book/chapter-6.sh
export LFS_ROOT_PASSWORD
/book/chapter-7.sh || exit $?
unset LFS_ROOT_PASSWORD
/book/chapter-8.sh
/book/chapter-9.sh

# create dist
/image/image.sh
EOF
