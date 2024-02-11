#!/bin/sh

set -e

IMAGE_TAG=gcr.io/kyle-server-402706/hardhat-node:0.0.1
# --no-cache
docker buildx build --platform linux/amd64 --build-arg=PROGRAM_VER=0.0.1 -t $IMAGE_TAG .
docker push $IMAGE_TAG

IMAGE_TAG_LATEST=gcr.io/kyle-server-402706/hardhat-node:latest
docker tag $IMAGE_TAG $IMAGE_TAG_LATEST
docker push $IMAGE_TAG_LATEST

# git tag -a $1 -m "add tag for $1"
# git push origin main --tags

# gcloud container clusters get-credentials kyle-ingress-standard-cluster-1 --zone me-west1-a --project kyle-server-402706
