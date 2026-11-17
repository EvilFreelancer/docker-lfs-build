# Linux From Scratch builder in Docker container

This repository is a collection of scripts created especially to
automate the build process of Linux From Scratch (LFS).

Current stable version of LFS is 8.3

## How to use

You need to install `docker` and `docker-compose` before you begin,
if you not have it yet.

* https://docs.docker.com/install/#supported-platforms
* https://docs.docker.com/compose/install/

### Normal usage

Clone from github and prepare the repository:

    git clone https://github.com/EvilFreelancer/docker-lfs-build.git
    cd docker-lfs-build
    cp docker-compose.yml.dist docker-compose.yml

Start container:

    docker-compose up -d

Start building directly, preserving the configured container environment:

    docker-compose exec lfs /book/book.sh

Result of building will be in `dist` folder.

### Root password in the generated system

The builder locks root unless you supply a nonempty `LFS_ROOT_PASSWORD` at
runtime. The default empty value in `docker-compose.yml.dist` lets the container
start without a password, but the resulting ISO will not allow root password
login, including through `sulogin`.

Before starting the container, read and export the password in your host's Bash
shell so it does not appear in shell history:

```bash
read -r -s -p 'LFS root password > ' LFS_ROOT_PASSWORD
printf '\n'
export LFS_ROOT_PASSWORD
docker-compose up -d
unset LFS_ROOT_PASSWORD
docker-compose exec lfs /book/book.sh
```

Compose passes this value through the service's `environment` setting. Recreate
an existing container after changing the value. For a one-off build in a running
container, read and export it as above, then use
`docker-compose exec -e LFS_ROOT_PASSWORD lfs /book/book.sh` and unset it afterward.
Run the builder directly as shown. The interactive login shell clears the
environment in `.bashrc`.

The password must not contain a colon, carriage return or newline. The builder
uses the installed Shadow tools to create shadowed passwords and set root's
password. It disables tracing while handling the value and sends it to the
chroot over standard input. Missing or empty input leaves root locked and prints
a warning. Invalid input or a password configuration failure stops the build
before image generation.

Do not put the password in the Dockerfile or commit it to Compose files. Docker
stores container environment variables in its metadata, which Docker
administrators can inspect. Treat the generated images as sensitive because
they contain the root password hash. When using `docker run`, pass an exported
value with `-e LFS_ROOT_PASSWORD`.

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
      - ./dist:/dist
    # You can set any entrypoint what you like, for example "inf sleep"
    # by default here is ["/book/book.sh"]
    entrypoint: ["sleep", "inf"]
```

## Links

* [Unofficial LFS group in Discord](https://discord.gg/NUSW8yF)
* [Project on which this project is based](https://github.com/reinterpretcat/lfs)
