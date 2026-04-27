#!/usr/bin/env bash
set -euo pipefail

dnf5 install -y --setopt=install_weak_deps=False iscsi-initiator-utils dracut-network

mkdir -p /usr/lib/bootc/kargs.d
cat >/usr/lib/bootc/kargs.d/00-ipu-network.toml <<'EOF'
kargs = ["ip=192.168.0.2:::255.255.255.0::enp0s1f0:off", "netroot=iscsi:192.168.0.1::::iqn.e2000:acc", "acpi=force"]
EOF

mkdir -p /usr/lib/dracut/dracut.conf.d
cat >/usr/lib/dracut/dracut.conf.d/50-ipu-iscsi-network.conf <<'EOF'
dracutmodules+=" iscsi network "
EOF

mkdir -p /usr/lib/dracut/modules.d/35network-legacy
cat >/usr/lib/dracut/modules.d/35network-legacy/module-setup.sh <<'EOF'
#!/usr/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    return 0
}
EOF
chmod 0755 /usr/lib/dracut/modules.d/35network-legacy/module-setup.sh

kver="$(cd /usr/lib/modules && echo *)"
dracut -vf "/usr/lib/modules/${kver}/initramfs.img" "${kver}"

echo "ipu upstream customization complete"
