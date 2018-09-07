#!/bin/bash
set -e
echo "Building Gzip.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 19 MB"

# 6.64. The Gzip package contains programs for compressing and
# decompressing files.
tar -xf /sources/gzip-*.tar.xz -C /tmp/ \
  && mv /tmp/gzip-* /tmp/gzip \
  && pushd /tmp/gzip

# First, make some fixes required by glibc-2.28:
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

# Prepare Gzip for compilation:
./configure --prefix=/usr

# Compile the package:
make

# NOTE two tests are known to fail in the LFS environment: help-version and zmore
if [ $LFS_TEST -eq 1 ]; then make check || true; fi

# Install the package:
make install

# Move a program that needs to be on the root filesystem:
mv -v /usr/bin/gzip /bin

# cleanup
popd \
  && rm -rf /tmp/gzip
