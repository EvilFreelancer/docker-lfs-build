#!/bin/bash
set -e
echo "Building findutils.."
echo "Approximate build time: 0.7 SBU"
echo "Required disk space: 51 MB"

# 6.53. Findutils package contains programs to find files
tar -xf /sources/findutils-*.tar.gz -C /tmp/ \
  && mv /tmp/findutils-* /tmp/findutils \
  && pushd /tmp/findutils

# First, suppress a test which on some machines can loop forever:
sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in

# Next, make some fixes required by glibc-2.28:
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h

# Prepare Findutils for compilation:
./configure --prefix=/usr --localstatedir=/var/lib/locate

make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

# cleanup
popd \
  && rm -rf /tmp/findutils
