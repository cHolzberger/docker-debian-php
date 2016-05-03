#!/bin/sh 
REPO=mosaiksoftware/debian-php

SCRIPTPATH=$(realpath "$0")
DIRNAME=$(dirname "$SCRIPTPATH")

cd $(dirname "$DIRNAME")

echo " >>> Building Image: $REPO"

docker build -t $REPO:tmp .

echo ">>> Flattening Image"
IMG=$(docker run -d $REPO:tmp /bin/true) 

docker export $IMG | \
docker import \
		--change 'ENTRYPOINT [ "/bin/docker-entrypoint" ]' \
		--change 'CMD /run.sh' \
		- $REPO:latest

echo ">>> Flattening onbuild Image"
 	docker export $IMG | \
	docker import \
		--change 'ENTRYPOINT [ "/bin/docker-entrypoint" ]' \
		--change 'CMD /run.sh' \
		--change 'ONBUILD COPY config /etc' \
		--change 'ONBUILD COPY selections /selections' \
		- $REPO:onbuild

docker stop $IMG
docker rm $IMG


echo ">>> Tagging latest image"
docker tag $REPO:latest $REPO

echo ">>> Pushing onbuild variant"
docker push $REPO:onbuild

echo ">>> Pushing flattened image"
docker push $REPO:latest
docker push $REPO

