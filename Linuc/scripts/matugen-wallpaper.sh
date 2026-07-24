#!/usr/bin/env bash
# Gera a paleta Material You a partir do wallpaper e aplica em
# hypr, waybar, kitty, gtk, dunst e hyprlock. Uso: matugen-wallpaper.sh /caminho/wall.jpg
set -euo pipefail

WALL="${1:?Uso: matugen-wallpaper.sh <caminho_da_imagem>}"
WALL_DIR="$HOME/.config/hypr/wallpapers"
LINK="$WALL_DIR/current.jpg"

mkdir -p "$WALL_DIR" "$HOME/.cache/linuc"

# hyprpaper guarda a textura em cache pelo CAMINHO do arquivo: só sobrescrever
# current.jpg não faz ele recarregar a imagem nova. Por isso alternamos entre
# dois nomes de arquivo reais (a/b) a cada troca, e current.jpg é sempre um
# link simbólico pro nome que está valendo -- assim hyprlock, SDDM etc.
# continuam apontando pro mesmo lugar estável.
OLD_REAL="$(readlink -f "$LINK" 2>/dev/null || true)"
if [ "$OLD_REAL" = "$WALL_DIR/wall-a.jpg" ]; then
  NEW_REAL="$WALL_DIR/wall-b.jpg"
else
  NEW_REAL="$WALL_DIR/wall-a.jpg"
fi

cp "$WALL" "$NEW_REAL"
ln -sfn "$NEW_REAL" "$LINK"

matugen image "$NEW_REAL" --mode dark --type scheme-tonal-spot

# Recarrega o hyprpaper de fato (preload da imagem nova, aplica, descarrega a antiga)
if command -v hyprctl >/dev/null 2>&1 && pgrep -x hyprpaper >/dev/null 2>&1; then
  hyprctl hyprpaper preload "$NEW_REAL" >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper ",$NEW_REAL" >/dev/null 2>&1 || true
  if [ -n "$OLD_REAL" ] && [ "$OLD_REAL" != "$NEW_REAL" ]; then
    hyprctl hyprpaper unload "$OLD_REAL" >/dev/null 2>&1 || true
  fi
fi

hyprctl reload
pkill -SIGUSR2 waybar 2>/dev/null || true
command -v dunstctl >/dev/null 2>&1 && dunstctl reload 2>/dev/null || true
echo "Paleta Material You aplicada a partir de $WALL"
echo "(pra levar essas cores/wallpaper também pra tela de login: ~/.config/linuc-scripts/sync-sddm-theme.sh — pede sudo)"
