# kyle-project-contracts

## Deploy (GKE)

The hardhat node runs as the `dex-app-hardhat` container of the
`dex-app-server-deployment` deployment, next to `dex-app-server` from kyle-dex.

1. Copy the gitignored `.env` from `~/kyle-config/src/kyle-server/env/hardhat.env`.
2. Build and push from a clean checkout of the commit to release. The image
   is tagged with the commit and `latest`, and earlier images are kept:
   `./push2gke_artifact.sh`
3. Point the container at the commit tag with the command step 2 printed:
   `./set_image.sh dex-app-server-deployment dex-app-hardhat <image>:<commit>`
4. To roll back, run the command that step 3 printed before the rollout. It
   names the digest that was running.

A rollout restarts both containers of the pod, and this container deploys
the contracts again when it starts (`scripts/prod/init.sh`).
