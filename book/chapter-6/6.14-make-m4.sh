#!/bin/bash
set -e
echo "Building M4.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 33 MB"

# 6.14. The M4 package contains a macro processor.
tar -xf /sources/m4-*.tar.xz -C /tmp/ \
  && mv /tmp/m4-* /tmp/m4 \
  && pushd /tmp/m4

# First, make some fixes required by glibc-2.28:
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

# Prepare M4 for compilation:
./configure --prefix=/usr

# Compile the package:
make

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install

popd \
  && rm -rf /tmp/m4
