#!/bin/bash
# Build and push dex-app-hardhat (a hardhat node with these contracts)
#
# The image is pushed with two tags: the commit it was built from and
# latest. Earlier images stay in Artifact Registry, so a bad release can be
# rolled back with set_image.sh. This script used to delete every version of
# the image before pushing, which left nothing to go back to.

set -euo pipefail

PROJECT_ID=kyle-server-402706
REPOSITORY=kyle-registry
LOCATION=me-west1
REGISTRY=$LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/dex-app-hardhat

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# The Dockerfile copies the gitignored .env into the image
if [ ! -f "$SCRIPT_DIR/.env" ]; then
  echo "Missing .env: copy ~/kyle-config/src/kyle-server/env/hardhat.env" >&2
  exit 1
fi

# The commit tag must name the code inside the image, so tracked files must
# match HEAD. The gitignored .env is not part of this check.
if ! git -C "$SCRIPT_DIR" diff --quiet HEAD --; then
  echo "Commit or stash these changes before pushing:" >&2
  git -C "$SCRIPT_DIR" status --short --untracked-files=no >&2
  exit 1
fi

TAG=$(git -C "$SCRIPT_DIR" rev-parse --short=12 HEAD)

# Build for linux/amd64 platform (GKE requirement) and push both tags
docker buildx build --no-cache --platform linux/amd64 \
  --build-arg=PROGRAM_VER="$TAG" \
  --push -t "$REGISTRY:$TAG" -t "$REGISTRY:latest" \
  -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

echo
echo "Pushed $REGISTRY:$TAG (also tagged latest)"
echo "Deploy it with: $SCRIPT_DIR/set_image.sh dex-app-server-deployment dex-app-hardhat $REGISTRY:$TAG"
