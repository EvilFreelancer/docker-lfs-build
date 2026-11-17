#!/bin/bash
# This script receives the password only on stdin, before other configuration.
set +x
set -e
set -o pipefail

# Chapter 6 cannot run pwconv yet. Use the completed system's Shadow tools.
pwconv
passwd -l root

# Read through EOF without trimming whitespace or trailing newlines.
root_password=
IFS= read -r -d '' root_password || true
case "$root_password" in
  *:*|*$'\n'*|*$'\r'*)
    echo "ERROR: LFS_ROOT_PASSWORD must not contain colons or newlines." >&2
    exit 1
    ;;
esac

if [ -n "$root_password" ]; then
  printf 'root:%s\n' "$root_password" | chpasswd -c SHA512
else
  echo "WARNING: LFS_ROOT_PASSWORD is unset or empty; root is locked in the generated system. Set it and rebuild to enable root login." >&2
fi
unset root_password
