#!/bin/bash
set -e
echo "Building make.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 13 MB"

# 5.28. The Make package contains a program for compiling packages.
tar -xf /sources/make-*.tar.bz2 -C /tmp/ \
 && mv /tmp/make-* /tmp/make \
 && pushd /tmp/make \
 && sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c \
 && ./configure --prefix=/tools --without-guile \
 && make \
 && if [ $LFS_TEST -eq 1 ]; then make check; fi \
 && make install \
 && popd \
 && rm -rf /tmp/make
