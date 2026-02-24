#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <image-ref>"
  exit 1
fi

image_ref="$1"

required_bins=(
  kubeadm
  kubelet
  kubectl
  cloud-init
  crio
  ovs-vsctl
  nmcli
  ip
)

for bin in "${required_bins[@]}"; do
  echo "checking binary: ${bin}"
  podman run --rm --entrypoint /usr/bin/bash "${image_ref}" -lc "command -v ${bin} >/dev/null"
done

echo "image verification succeeded: ${image_ref}"
