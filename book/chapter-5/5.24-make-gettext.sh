#!/bin/bash
set -e
echo "Building gettext.."
echo "Approximate build time: 0.9 SBU"
echo "Required disk space: 173 MB"

cd /sources

# 5.24. Gettext package contains utilities for internationalization and
# localization. These allow programs to be compiled with NLS (Native Language
# Support), enabling them to output messages in the user's native language
tar -xf gettext-*.tar.xz -C /tmp/ \
  && mv /tmp/gettext-* /tmp/gettext \
  && pushd /tmp/gettext \
  && cd gettext-tools \
  && EMACS="no" ./configure --prefix=/tools --disable-shared \
  && make -C gnulib-lib \
  && make -C intl pluralx.c \
  && make -C src msgfmt \
  && make -C src msgmerge \
  && make -C src xgettext \
  && cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin \
  && popd \
  && rm -rf /tmp/gettext
