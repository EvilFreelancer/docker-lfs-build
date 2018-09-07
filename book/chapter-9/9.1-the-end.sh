#!/bin/bash
set -e
echo "Finalize LFS configuration.."

# LFS version file
echo 8.3 > /etc/lfs-release

# LSB version file
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="8.3"
DISTRIB_CODENAME="EvilFreelancer"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

# add login logo
cat > /etc/issue << "EOF"
Linux From Scratch \n \l
EOF
