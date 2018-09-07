#!/bin/bash
set -e
echo "Building Bison.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 35 MB"

# 6.31. Bison package contains a parser generator
tar -xf /sources/bison-*.tar.xz -C /tmp/ \
  && mv /tmp/bison-* /tmp/bison \
  && pushd /tmp/bison

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.5
make
make install
# cleanup
popd \
  && rm -rf /tmp/bison
