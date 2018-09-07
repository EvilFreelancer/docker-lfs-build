#!/bin/bash
set -e
echo "Building Attr.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 4.2 MB"

# 6.24. The Attr package contains utilities to administer the extended
# attributes on filesystem objects
tar -xf /sources/attr-*.tar.gz -C /tmp/ \
  && mv /tmp/attr-* /tmp/attr \
  && pushd /tmp/attr

# Prepare Attr for compilation:
./configure --prefix=/usr     \
            --bindir=/bin     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.4.48

# Compile the package:
make

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install

# The shared library needs to be moved to /lib, and as a result the
# .so file in /usr/lib will need to be recreated:
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

# Cleanup
popd \
  && rm -rf /tmp/attr
