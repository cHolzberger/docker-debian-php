#!/bin/sh 
REPO=mosaiksoftware/debian-php

cd ..
docker build -t $REPO .
docker push $REPO

