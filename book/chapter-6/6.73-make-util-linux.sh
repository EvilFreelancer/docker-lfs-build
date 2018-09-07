#!/bin/bash
set -e
echo "Building Util-linux.."
echo "Approximate build time: 1.1 SBU"
echo "Required disk space: 200 MB"

# 6.73. The Util-linux package contains miscellaneous utility programs. Among
# them are utilities for handling file systems, consoles, partitions, and messages
tar -xf /sources/util-linux-*.tar.xz -C /tmp/ \
  && mv /tmp/util-linux-* /tmp/util-linux \
  && pushd /tmp/util-linux

# Remove the earlier created symlinks:
rm -vf /usr/include/{blkid,libmount,uuid}

# Prepare Util-linux for compilation:
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.32.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir

# Compile the package:
make

echo "Util-linux test skipped due to warning."
#if [ $LFS_TEST -eq 1 ]; then
#    chown -Rv nobody .
#    su nobody -s /bin/bash -c "PATH=$PATH make -k check"
#fi

# install
make install

# cleanup
popd \
  && rm -rf /tmp/util-linux
