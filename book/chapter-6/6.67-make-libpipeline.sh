#!/bin/bash
set -e
echo "Building libpipeline.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 8.2 MB"

# 6.67. Libpipeline package contains a library for manipulating
# pipelines of subprocesses in a flexible and convenient way
tar -xf /sources/libpipeline-*.tar.gz -C /tmp/ \
  && mv /tmp/libpipeline-* /tmp/libpipeline \
  && pushd /tmp/libpipeline

# prepare
./configure --prefix=/usr

# compile, test and install
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install

# cleanup
popd \
  && rm -rf /tmp/libpipeline
