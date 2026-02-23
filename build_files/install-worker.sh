#!/usr/bin/env bash
set -euo pipefail

# Worker image currently shares the full common package set.
# Keep role-specific changes here (for example removing control-plane extras).
echo "worker role customization complete"
