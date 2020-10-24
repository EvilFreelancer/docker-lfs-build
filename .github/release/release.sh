docker build . -t evilfreelancer-docker-lfs-build
cp docker-compose.yml.dist docker-compose.yml
sed -i 's|evilfreelancer/docker-lfs-build|evilfreelancer-docker-lfs-build|g' docker-compose.yml
docker-compose up