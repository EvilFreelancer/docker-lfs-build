#!/bin/bash
set -e
echo "Building perl.."
echo "Approximate build time: 1.5 SBU"
echo "Required disk space: 275 MB"

# 5.30. Perl package contains the Practical Extraction and Report Language
tar -xf /sources/perl-5*.tar.xz -C /tmp/ \
  && mv /tmp/perl-* /tmp/perl \
  && pushd /tmp/perl \
  && sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth \
  && make \
  && cp -v perl cpan/podlators/scripts/pod2man /tools/bin \
  && mkdir -pv /tools/lib/perl5/5.28.0 \
  && cp -Rv lib/* /tools/lib/perl5/5.28.0 \
  && popd \
  && rm -rf /tmp/perl
