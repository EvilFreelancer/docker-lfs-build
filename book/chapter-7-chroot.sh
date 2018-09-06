#!/bin/bash -x

echo "> Configure system..."

sh /book/chapter-7/7.2-make-lfs-bootscripts.sh
sh /book/chapter-7/7.4-manage-devices.sh
sh /book/chapter-7/7.5-configure-network.sh
sh /book/chapter-7/7.6-configure-systemv.sh
sh /book/chapter-7/7.x-configure-bash.sh

exit
