#!/bin/bash
set -e
echo "Building Tcl-core.."
echo "Approximate build time: 0.9 SBU"
echo "Required disk space: 66 MB"

# 5.11. The Tcl package contains the Tool Command Language.
tar -xf /sources/tcl*-src.tar.gz -C /tmp/ \
  && mv /tmp/tcl* /tmp/tcl \
  && pushd /tmp/tcl

# Prepare Tcl for compilation:
cd unix
./configure --prefix=/tools

# Build the package:
make

# Run tests
if [ $LFS_TEST -eq 1 ]; then TZ=UTC make test; fi

# Install the package:
make install

# Make the installed library writable so debugging symbols can be removed later:
chmod -v u+w /tools/lib/libtcl8.6.so

# Install Tcl's headers. The next package, Expect, requires them to build.
make install-private-headers

# Now make a necessary symbolic link:
ln -sv tclsh8.6 /tools/bin/tclsh || true

popd \
  && rm -rf /tmp/tcl-core
