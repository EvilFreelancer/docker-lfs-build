#!/bin/bash
set -e
echo "Cleaning up.."

# 6.80. Cleaning Up

# workaround for https://github.com/moby/moby/issues/13451
pushd /tmp/
for i in $(ls -d */); do
  while [[ -e  ${i%%/}/confdir3/confdir3 ]]; do
    mv confdir3/confdir3 confdir3a; rmdir confdir3; mv confdir3a confdir3;
  done;
done;
popd

# Finally, clean up some extra files left around from running tests:
rm -rf /tmp/*

# cleanup leftovers
rm -f /usr/lib/lib{bfd,opcodes}.a
rm -f /usr/lib/libbz2.a
rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -f /usr/lib/libltdl.a
rm -f /usr/lib/libfl.a
rm -f /usr/lib/libz.a

find /usr/lib /usr/libexec -name \*.la -delete
