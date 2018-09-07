#!/bin/bash
set -e
echo "Building Inetutils.."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 29 MB"

# 6.39. The Inetutils package contains programs for basic networking.
tar -xf /sources/inetutils-*.tar.xz -C /tmp/ \
  && mv /tmp/inetutils-* /tmp/inetutils \
  && pushd /tmp/inetutils

# prepare
./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

# Compile the package:
make

# One test, libls.sh, may fail in the initial chroot environment but will pass
# if the test is rerun after the LFS system is complete
if [ $LFS_TEST -eq 1 ]; then make check || true; fi

# Install the package:
make install

# Move some programs so they are available if /usr is not accessible:
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

# cleanup
popd \
  && rm -rf /tmp/inetutils
