#!/usr/bin/env bash
set -euo pipefail

dnf5 clean all

# Avoid removing build cache mount roots (e.g. /var/cache/dnf) during podman/buildah runs.
find /var/cache -mindepth 1 -maxdepth 1 ! -name dnf -exec rm -rf {} +
rm -rf /var/cache/dnf/* /var/tmp/* /tmp/*

# Keep /var/log clean for bootc lint.
find /var/log -mindepth 1 -exec rm -rf {} +
