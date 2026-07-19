#!/usr/bin/env bash
# Configura zram-generator automaticamente (sem swap em disco).
set -euo pipefail

sudo pacman -S --noconfirm --needed zram-generator

sudo tee /etc/systemd/zram-generator.conf > /dev/null <<'EOF'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service || true

echo "zram configurado (zstd, até metade da RAM, máx 4GB)."
