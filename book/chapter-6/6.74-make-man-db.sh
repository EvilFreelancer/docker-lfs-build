#!/bin/bash
set -e
echo "Building man-db.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 30 MB"

# 6.74. Man-DB package contains programs for finding and viewing man pages
tar -xf /sources/man-db-*.tar.xz -C /tmp/ \
  && mv /tmp/man-db-* /tmp/man-db \
  && pushd /tmp/man-db

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.8.4 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=

# Compile the package:
make

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install

# cleanup
popd \
  && rm -rf /tmp/man-db || true
