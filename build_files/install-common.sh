#!/usr/bin/env bash
set -euo pipefail

dnf5 install -y \
  kubelet \
  kubeadm \
  kubectl \
  cri-o \
  containernetworking-plugins \
  openvswitch \
  NetworkManager \
  NetworkManager-ovs \
  iproute \
  iptables \
  ethtool \
  jq \
  curl \
  wget \
  tmux

systemctl enable crio
systemctl enable kubelet
systemctl enable NetworkManager
systemctl enable openvswitch
