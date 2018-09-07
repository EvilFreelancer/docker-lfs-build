#!/bin/bash
set -e
echo "Building Meson.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 21 MB"

# 6.51. Meson is an open source build system meant to be both extremely fast,
# and, even more importantly, as user friendly as possible.
tar -xf /sources/meson-*.tar.gz -C /tmp/ \
  && mv /tmp/meson-* /tmp/meson \
  && pushd /tmp/meson

# Compile Meson with the following command:
python3 setup.py build

# Install the package:
python3 setup.py install --root=dest
cp -rv dest/* /

# cleanup
popd \
  && rm -rf /tmp/meson
