#!/bin/bash
set -e
echo "Building Coreutils.."
echo "Approximate build time: 0.7 SBU"
echo "Required disk space: 147 MB"

# 5.19. The Coreutils package contains utilities for showing and
# setting the basic system characteristics.

# NOTE: has failed tests
# NOTE: has workaround for deletion directories with long name

tar -xf /sources/coreutils-*.tar.xz -C /tmp/ \
  && mv /tmp/coreutils-* /tmp/coreutils \
  && pushd /tmp/coreutils \
  && FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/tools --enable-install-program=hostname \
  && FORCE_UNSAFE_CONFIGURE=1 make \
  && if [ $LFS_TEST -eq 1 ]; then make RUN_EXPENSIVE_TESTS=yes check || true; fi \
  && make install \
  && popd \
  && rm -rf /tmp/coreutils
