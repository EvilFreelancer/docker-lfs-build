#!/bin/bash -x

echo "> Make system bootable..."

sh /book/chapter-8/8.2-create-fstab.sh
sh /book/chapter-8/8.3-make-linux-kernel.sh
sh /book/chapter-8/8.4-setup-grub.sh

exit
