#!/usr/bin/env bash
set -euo pipefail

dnf5 install -y --setopt=install_weak_deps=False \
  kubelet \
  kubeadm \
  kubectl \
  cloud-init \
  cri-o \
  iproute-tc \
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

# Match dpu-sim expectations: CRI-O on Fedora looks under /opt/cni/bin.
mkdir -p /opt/cni/bin
shopt -s nullglob
for plugin in /usr/libexec/cni/*; do
  ln -sf "${plugin}" /opt/cni/bin/
done
shopt -u nullglob

# Kubernetes node prerequisites.
cat >/etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

cat >/etc/sysctl.d/k8s.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Disable zram-backed swap generation by default.
cat >/etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = 0
EOF

# Enforce swap-off on every boot before kubelet starts.
mkdir -p /usr/local/sbin
cat >/usr/local/sbin/dpu-disable-swap.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

/usr/sbin/swapoff -a || true
if [[ -f /etc/fstab ]]; then
  /usr/bin/sed -i '/ swap / s/^/#/' /etc/fstab
fi
EOF
chmod 0755 /usr/local/sbin/dpu-disable-swap.sh

cat >/usr/lib/systemd/system/dpu-disable-swap.service <<'EOF'
[Unit]
Description=Disable swap for Kubernetes nodes
After=local-fs.target
Before=kubelet.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dpu-disable-swap.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# firewalld is explicitly disabled in dpu-sim setup path.
if rpm -q firewalld >/dev/null 2>&1; then
  systemctl disable --now firewalld || true
  dnf5 remove -y firewalld || true
fi

systemctl enable crio
systemctl enable kubelet
systemctl enable dpu-disable-swap.service
systemctl enable NetworkManager
systemctl enable openvswitch
