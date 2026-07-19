#!/usr/bin/env bash
# Instala e habilita o daemon gamemode (governor de CPU + prioridade em jogos).
set -euo pipefail

sudo pacman -S --noconfirm --needed gamemode

mkdir -p ~/.config
cat > ~/.config/gamemode.ini <<'EOF'
[general]
renice=10
ioprio=0

[cpu]
park_cores=no
pin_cores=yes

[custom]
start=notify-send "Gamemode" "Ativado"
end=notify-send "Gamemode" "Desativado"
EOF

echo "gamemode instalado. Uso: gamemoderun %command% (Steam/Lutris) ou 'gamemoded -t' manualmente."
