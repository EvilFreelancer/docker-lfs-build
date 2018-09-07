#!/bin/bash
set -e
echo "Building grub.."
echo "Approximate build time: 0.8 SBU"
echo "Required disk space: 147 MB"

# 6.62. GRUB package contains the GRand Unified Bootloader
tar -xf /sources/grub-*.tar.xz -C /tmp/ \
  && mv /tmp/grub-* /tmp/grub \
  && pushd /tmp/grub

# Prepare GRUB for compilation:
./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror

# Compile the package:
make

# Install the package:
make install

# cleanup
popd \
  && rm -rf /tmp/grub
