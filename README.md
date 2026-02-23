# dpu-image-factory

Build and publish reproducible bootc system and Kubernetes node images for simulation and device targets, with CI validation, signing, and versioned artifact delivery.

## What This Repo Produces

Current bootc image variants:
- `dpu-sim-control-plane`
- `dpu-sim-worker`

Both are built from a shared base stage in `Containerfile`:
- `dpu-sim-base`

Future scope:
- additional node/kind images in this same factory repo.

## Repository Layout

- `Containerfile`: multi-stage bootc image build (`dpu-sim-base`, role stages)
- `build_files/install-common.sh`: common packages and service enables
- `build_files/install-control-plane.sh`: control-plane role customizations
- `build_files/install-worker.sh`: worker role customizations
- `build_files/verify-packages.sh`: required binary checks for CI/local
- `disk_config/disk.toml`: qcow2/raw image customization
- `.github/workflows/build.yml`: entry workflow matrix (role + arch)
- `.github/workflows/reusable-build-image.yml`: reusable build/push/sign workflow

## Local Build

### 1) Build a role image

```bash
cd /var/home/sadasilv/Projects/dpu-dev/dpu-image-factory

podman build --target dpu-sim-control-plane -t localhost/dpu-sim-control-plane:dev .
# or
podman build --target dpu-sim-worker -t localhost/dpu-sim-worker:dev .
```

### 2) Verify required binaries

```bash
just verify control-plane dev
```

### 3) Build a VM disk artifact (qcow2)

```bash
just build-qcow2 localhost/dpu-sim-control-plane dev
```

Artifacts are written under `output/`.

## Local VM Test (ARM64 and x86)

Recommended runner:

```bash
sudo just spawn-vm 0 qcow2 4G native
```

Notes:
- `spawn-vm` auto-selects AArch64 UEFI firmware on ARM hosts.
- `spawn-vm` resolves the actual disk file under `output/` (including symlinked output dirs).
- For qcow2, `spawn-vm` converts to a temporary raw image before launch (vmspawn/QEMU compatibility workaround).

Guest test login:
- user: `dpu-sim`
- password: `dpu-sim`

Quick validation inside guest:

```bash
whoami
kubeadm version
kubelet --version
crio --version
```

This repo already includes `Justfile` fixes for non-POSIX filesystems (for example `vfat`) when staging artifacts.

## CI Behavior

- Builds both role images for `amd64` and `arm64`
- Runs required-binary checks (`verify-packages.sh`)
- Pushes images to GHCR on default branch
- Signs pushed images via Cosign (`SIGNING_SECRET`)

## Security Note

The current local test credentials are intentionally simple for simulation workflows.
For shared or production-like environments, replace them in `disk_config/disk.toml`.
