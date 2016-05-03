docker build -f ./Dockerfile-build-php  -t phpfarm-build .
docker run --rm --name phpfarm -v `pwd`/pkg:/pkg phpfarm-build

