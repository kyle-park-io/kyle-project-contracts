#!/bin/bash
# Point one container of a deployment at an image and wait for the rollout.
#
# Usage: set_image.sh <deployment> <container> <image>:<tag or @digest>
#
# Before changing anything it prints the digest the container runs now, and
# the command that puts it back. Deploy by commit tag rather than latest:
# with latest, kubectl rollout undo returns to a template that already points
# at the new image.
#
# All containers of the pod restart on a rollout, not only <container>.

set -euo pipefail

if [ $# -ne 3 ]; then
  echo "Usage: $0 <deployment> <container> <image>:<tag>" >&2
  exit 1
fi
deployment=$1
container=$2
image=$3

selector=$(kubectl get deployment "$deployment" \
  -o go-template='{{range $k, $v := .spec.selector.matchLabels}}{{$k}}={{$v}},{{end}}')
selector=${selector%,}

previous=$(kubectl get pods -l "$selector" \
  -o jsonpath="{.items[0].status.containerStatuses[?(@.name=='$container')].imageID}")
if [ -z "$previous" ]; then
  echo "No running container named $container in $deployment" >&2
  exit 1
fi
previous=${previous#docker-pullable://}

echo "Running now: $previous"
echo "Roll back with: $0 $deployment $container $previous"
echo

kubectl set image "deployment/$deployment" "$container=$image"

# Copied from kyle-cex-bot, where rollouts took 41 s from pod scheduled to
# ready (2026-11-16) and 11 s from set image to rolled out (2026-11-19). This
# pod has not been timed with it; wait up to 240 s before reporting it stuck.
kubectl rollout status "deployment/$deployment" --timeout=240s
