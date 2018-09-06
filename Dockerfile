FROM debian:9

# image info
LABEL description="Automated LFS build"
LABEL version="8.3"
LABEL maintainer="paul@drteam.rocks"

# LFS mount point
ENV LFS=/lfs

# Other LFS parameters
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV MAKEFLAGS="-j 1"

# set 1 to run tests; running tests takes much more time
ENV LFS_TEST=0

# set 1 to install documentation; slightly increases final size
ENV LFS_DOCS=0

# degree of parallelism for compilation
ENV JOB_COUNT=1

# loop device
ENV LOOP=/dev/loop0

# inital ram disk size in KB
# must be in sync with CONFIG_BLK_DEV_RAM_SIZE
ENV IMAGE_SIZE=800000

# location of initrd tree
ENV INITRD_TREE=$LFS

# output image
ENV IMAGE=isolinux/ramdisk.img

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# install required packages
RUN apt-get update && apt-get install -y \
    build-essential                      \
    bison                                \
    file                                 \
    gawk                                 \
    texinfo                              \
    wget                                 \
    sudo                                 \
    genisoimage                          \
 && apt-get -q -y autoremove             \
 && rm -rf /var/lib/apt/lists/*

# create sources directory as writable and sticky
RUN mkdir -pv     $LFS/sources   \
 && chmod -v a+wt $LFS/sources   \
 && ln    -sv     $LFS/sources /

# create book directory as writable and sticky
RUN mkdir -pv     $LFS/book   \
 && chmod -v a+wt $LFS/book   \
 && ln    -sv     $LFS/book /

# create image directory as writable and sticky
RUN mkdir -pv     $LFS/image   \
 && chmod -v a+wt $LFS/image   \
 && ln    -sv     $LFS/image /

# Copy additional scripts and archives
COPY ["book/", "$LFS/book/"]
COPY ["image/", "$LFS/image/"]
COPY ["sources/", "$LFS/sources/"]

# create tools directory and symlink
RUN mkdir -pv $LFS/tools   \
 && ln    -sv $LFS/tools /

# check environment
RUN $LFS/book/version-check.sh \
 && $LFS/book/library-check.sh

# create lfs user with 'lfs' password
RUN groupadd lfs                                    \
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd
RUN adduser lfs sudo

# give lfs user ownership of directories
RUN chown -v lfs $LFS/tools  \
 && chown -v lfs $LFS/sources

# avoid sudo password
RUN echo "lfs ALL = NOPASSWD : ALL" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LFS LC_ALL LFS_TGT PATH MAKEFLAGS FETCH_TOOLCHAIN_MODE LFS_TEST LFS_DOCS JOB_COUNT LOOP IMAGE_SIZE INITRD_TREE IMAGE"' >> /etc/sudoers

# login as lfs user
USER lfs
COPY [ ".bash_profile", ".bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# Download all sources
RUN /book/chapter-3.sh

# let's the party begin
ENTRYPOINT [ "/book/book.sh" ]
