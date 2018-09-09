#!/bin/bash
set -e
echo "Building e2fsprogs.."
echo "Approximate build time: 1.6 SBU"
echo "Required disk space: 96 MB"

# 6.55. The E2fsprogs package contains the utilities for handling
# the ext2 file system. It also supports the ext3 and ext4 journaling
# file systems.
tar -xf /sources/e2fsprogs-*.tar.gz -C /tmp/ \
  && mv /tmp/e2fsprogs-* /tmp/e2fsprogs \
  && pushd /tmp/e2fsprogs

# The E2fsprogs documentation recommends that the package be built in
# a subdirectory of the source tree:
mkdir -v build
cd build

# Prepare E2fsprogs for compilation:
# http://lists.linuxfromscratch.org/pipermail/lfs-support/2016-August/050256.html
LIBS=-L/tools/lib                    \
CFLAGS=-I/tools/include              \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

# Compile the package:
make

# To set up and run the test suite we need to first link some libraries
# from /tools/lib to a location where the test programs look. To run
# the tests, issue:
if [ $LFS_TEST -eq 1 ]; then
    ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
    make LD_LIBRARY_PATH=/tools/lib check || true
fi

# Install the binaries, documentation, and shared libraries:
make install

# Install the static libraries and headers:
make install-libs

# Make the installed static libraries writable so debugging symbols can be removed later:
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

# This package installs a gzipped .info file but doesn't update the system
# -wide dir file. Unzip this file and then update the system dir file using
# the following commands:
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

# create and install some additional documentation
if [ $LFS_DOCS -eq 1 ]; then
    makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
    install -v -m644 doc/com_err.info /usr/share/info
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
fi

# cleanup
popd \
  && rm -rf /tmp/e2fsprogs
