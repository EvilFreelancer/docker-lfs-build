#!/bin/bash
set -e
echo "Building less.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 3.9 MB"

# 6.63. Less package contains a text file viewer
tar -xf /sources/less-*.tar.gz -C /tmp/ \
  && mv /tmp/less-* /tmp/less \
  && pushd /tmp/less

# Prepare Less for compilation:
./configure --prefix=/usr --sysconfdir=/etc

# Compile the package:
make

# Install the package:
make install

# cleanup
popd \
  && rm -rf /tmp/less
