#!/bin/bash
set -e
echo "Building tar.."
echo "Approximate build time: 2.8 SBU"
echo "Required disk space: 44 MB"

# 6.75. Tar package contains an archiving program
tar -xf /sources/tar-*.tar.xz -C /tmp/ \
  && mv /tmp/tar-* /tmp/tar \
  && pushd /tmp/tar

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin

# Compile the package:
make

# To test the results (about 3 SBU), issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.30

# cleanup
popd \
  && rm -rf /tmp/tar || true
