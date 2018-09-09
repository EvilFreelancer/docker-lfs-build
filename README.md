# Linux From Scratch builder in Docker

This repository is a collection of scripts created especially to
automate the build process of Linux From Scratch (LFS).

## How to use

You need to install `docker` and `docker-compose` before you begin,
if you not have it yet.

### Normal usage

    git clone https://github.com/EvilFreelancer/docker-lfs-build.git
    cd docker-lfs-build
    cp docker-compose.yml.dist docker-compose.yml
    docker-compose build
    docker-compose up -d

Then login as LFS user:

    docker-compose exec lfs bash

Start building:

    sudo /book/book.sh

### Download from Docker Hub

    docker pull evilfreelancer/docker-lfs-build

### Create your custom `docker-compose.yml` file

```yml
version: '2'

services:
  lfs:
    restart: unless-stopped
    image: evilfreelancer/docker-lfs-build
    volumes:
      - ./book:/lfs/book
      - ./image:/lfs/image
      - ./sources:/lfs/sources
      - ./tools:/lfs/tools
    # You can set any entrypoint what you like, for example "inf sleep"
    entrypoint: ["sleep", "inf"]
```

## Links

* [Unofficial LFS group in Discord](https://discord.gg/NUSW8yF)
* [Project on which this project is based](https://github.com/reinterpretcat/lfs)
