#!/usr/bin/env bash
# ~/.config/linuc-scripts/wallpaper-picker.sh
# Seletor de wallpaper com preview da imagem em tempo real (fzf + kitty icat).
# SUPER+W abre isso numa janela flutuante do kitty.
set -euo pipefail

WALL_DIR="${1:-$HOME/Imagens/Wallpapers}"
mkdir -p "$WALL_DIR"

# se a pasta tiver vazia, avisa e sai
if [ -z "$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print -quit)" ]; then
  echo "Nenhuma imagem em $WALL_DIR"
  echo "Coloque wallpapers ali (.jpg/.jpeg/.png/.webp) e rode de novo."
  read -n 1 -s -r -p "Pressione qualquer tecla pra fechar..."
  exit 0
fi

choice=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort |
  fzf --height=100% --layout=reverse --border \
      --prompt="🖼  Wallpaper > " \
      --preview="kitty +kitten icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 '$WALL_DIR/{}' 2>/dev/null" \
      --preview-window=right:60%)

[ -z "$choice" ] && exit 0

~/.config/linuc-scripts/matugen-wallpaper.sh "$WALL_DIR/$choice"
notify-send "Linuc" "Wallpaper aplicado: $choice" 2>/dev/null || true
