#!/bin/sh

PROJECT_ID=kyle-server-402706
REPOSITORY=kyle-registry
LOCATION=me-west1
IMAGE=hardhat-node
TAG=0.0.1
TAG_LATEST=latest

set -e

# delete existing image
# untag
gcloud artifacts docker tags delete $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE:$TAG --quiet || true
gcloud artifacts docker tags delete $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE:$TAG_LATEST --quiet || true
# delete
# --filter="tags:$TAG" --format="get(DIGEST)" --limit=1
DIGEST=$(gcloud artifacts docker images list $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY --filter="PACKAGE: $IMAGE" --format="get(DIGEST)" --limit=1)
gcloud artifacts docker images delete $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE@$DIGEST --quiet || true

# push 0.0.1
# IMAGE_TAG=me-west1-docker.pkg.dev/kyle-server-402706/kyle-registry/dex-node:0.0.1
IMAGE_TAG=$LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE:$TAG
docker buildx build --no-cache --platform linux/amd64 --build-arg=PROGRAM_VER=0.0.1 -t $IMAGE_TAG .
docker push $IMAGE_TAG

# push latest
IMAGE_TAG_LATEST=$LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE:$TAG_LATEST
docker tag $IMAGE_TAG $IMAGE_TAG_LATEST
docker push $IMAGE_TAG_LATEST
