#!/usr/bin/env bash
set -e

docker run --rm \
  -v "$(pwd):/workspace" \
  -v nix-store-cache:/nix \
  -w /workspace \
  nixos/nix \
  sh -c '
    git config --global --add safe.directory /workspace && \
    nix --extra-experimental-features "nix-command flakes" run .#default
  ' | docker load
