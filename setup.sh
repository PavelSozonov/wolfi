#!/usr/bin/env bash
set -euo pipefail

# Directory to hold the offline mirror
OFFLINE_DIR="$(pwd)/wolfi_offline"
mkdir -p "$OFFLINE_DIR/os/x86_64"

docker run --rm --platform linux/amd64 \
  -v "$OFFLINE_DIR":/offline:rw \
  cgr.dev/chainguard/wolfi-base:latest \
  sh -euxc '
    # 1) Point at the root "os" repository (APK will append x86_64 automatically)
    echo "https://packages.wolfi.dev/os" > /etc/apk/repositories

    # 2) Download and cache the index so that `apk fetch` can use it
    apk update

    # 3) Install the tools needed to mirror the index and packages
    apk add --no-cache wget

    # 4) Mirror the Wolfi APKINDEX into your offline directory
    wget -qO /offline/os/x86_64/APKINDEX.tar.gz \
      https://packages.wolfi.dev/os/x86_64/APKINDEX.tar.gz

    # 5) Fetch the actual .apk binaries into the container’s working dir
    apk fetch --recursive ca-certificates openssl wget python-3.13 curl nodejs-22 build-base

    # 6) Move the binaries into your offline repo layout
    mv *.apk /offline/os/x86_64/
  '

echo "Offline Wolfi mirror prepared at: $OFFLINE_DIR/os/x86_64"
echo "Contents:"
ls -1 "$OFFLINE_DIR/os/x86_64"
