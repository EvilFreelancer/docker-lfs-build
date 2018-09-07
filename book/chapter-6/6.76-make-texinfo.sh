#!/bin/bash
set -e
echo "Building texinfo.."
echo "Approximate build time: 1.1 SBU"
echo "Required disk space: 129 MB"

# 6.76. Texinfo package contains programs for reading, writing,
# and converting info pages
tar -xf /sources/texinfo-*.tar.xz -C /tmp/ \
  && mv /tmp/texinfo-* /tmp/texinfo \
  && pushd /tmp/texinfo

# Fix a file that creates a lot of failures in the regression checks:
sed -i '5481,5485 s/({/(\\{/' tp/Texinfo/Parser.pm

# Prepare Texinfo for compilation:
./configure --prefix=/usr --disable-static

# Compile the package:
make

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make check; fi

# Install the package:
make install

# Optionally, install the components belonging in a TeX installation:
make TEXMF=/usr/share/texmf install-tex

# fix package out of sync with the info pages installed on the system
pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd

# cleanup
popd \
  && rm -rf /tmp/texinfo
