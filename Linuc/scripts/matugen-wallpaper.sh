#!/usr/bin/env bash
# Gera a paleta Material You a partir do wallpaper e aplica em
# hypr, waybar, kitty, gtk e kvantum. Uso: matugen-wallpaper.sh /caminho/wall.jpg
set -euo pipefail

WALL="${1:?Uso: matugen-wallpaper.sh <caminho_da_imagem>}"
DEST=~/.config/hypr/wallpapers/current.jpg

mkdir -p ~/.config/hypr/wallpapers
cp "$WALL" "$DEST"

# matugen lê os templates em ~/.config/matugen/templates/ (instalados pelo install.sh)
# e escreve direto em hypr/colors.lua, kitty/colors.conf, waybar/style.css e no tema kvantum.
matugen image "$DEST" --mode dark --type scheme-tonal-spot

hyprctl reload
pkill -SIGUSR2 waybar 2>/dev/null || true
command -v dunstctl >/dev/null 2>&1 && dunstctl reload 2>/dev/null || true
echo "Paleta Material You aplicada a partir de $WALL"
