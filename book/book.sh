#!/bin/bash -x

# prepare to build
/book/chapter-3.sh

# execute rest as root
exec sudo -E -u root /bin/sh - <<EOF
#  change ownership
chown -R root:root $LFS/tools

# prevent "bad interpreter: Text file busy"
sync

# continue
/book/chapter-5.sh
/book/chapter-6.sh
/book/chapter-7.sh
/book/chapter-8.sh
/book/chapter-9.sh

# create dist
/image/image.sh
EOF
