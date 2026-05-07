#!/usr/bin/env bash

# Exit immediately if a command or pipeline fails
set -e

echo "Building 'my-dev-env' Docker image via Nix..."

# Run the official Nix image ephemerally to build our container
docker run --rm \
  \
  `# Mount the current repository directory into the container at /app` \
  -v "$(pwd):/app" \
  \
  `# Mount a named volume to cache the Nix store.` \
  `# This ensures subsequent builds are instantaneous instead of re-downloading dependencies.` \
  -v nix-store-cache:/nix \
  \
  `# Set the container working directory to where we mounted the code` \
  -w /app \
  \
  `# Use the official NixOS base image` \
  nixos/nix \
  \
  `# Wrap our commands in a shell string so we can run multiple steps safely` \
  sh -c '
    # 1. Bypass Git security quirk (CVE-2022-24765)
    # The container runs as root, but the mounted files are owned by your host user.
    # We must explicitly tell git that this directory is safe to read.
    git config --global --add safe.directory /app && \
    
    # 2. Run the Nix build
    # We explicitly enable flakes and nix-commands. 
    # Because of our flake.nix "apps" configuration, "run .#default" executes 
    # the streamLayeredImage script, dumping the OCI archive directly to stdout.
    nix --extra-experimental-features "nix-command flakes" run .#default
  ' | \
  \
  `# Catch the stdout stream from the container and feed it directly into the host Docker daemon` \
  docker load

echo ""
echo "✅ Build complete! You can now use the image."
echo "Test it with: docker run -it --rm my-dev-env:latest"
