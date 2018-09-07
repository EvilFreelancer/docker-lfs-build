#!/bin/bash
set -e
echo "Building gettext.."
echo "Approximate build time: 2.6 SBU"
echo "Required disk space: 210 MB"

# 6.47. Gettext package contains utilities for internationalization and
# localization. These allow programs to be compiled with NLS
# (Native Language Support), enabling them to output messages in the
# user's native language
tar -xf /sources/gettext-*.tar.xz -C /tmp/ \
  && mv /tmp/gettext-* /tmp/gettext \
  && pushd /tmp/gettext

# First, suppress two invocations of test-lock which on some machines can loop forever:
sed -i '/^TESTS =/d' gettext-runtime/tests/Makefile.in &&
sed -i 's/test-lock..EXEEXT.//' gettext-tools/gnulib-tests/Makefile.in

# Now fix a configuration file:
sed -e '/AppData/{N;N;p;s/\.appdata\./.metainfo./}' \
    -i gettext-tools/its/appdata.loc

# prepare for compilation
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1

# compile, test, install
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
# cleanup
popd \
  && rm -rf /tmp/gettext
