#!/usr/bin/env bash
# ~/.config/linuc-scripts/sync-sddm-theme.sh
# Copia a paleta Material You (gerada pelo matugen) e o wallpaper atual pro
# tema do SDDM. Precisa de sudo porque o tema mora em /usr/share (área do
# sistema) — o SDDM roda como outro usuário e não enxerga sua $HOME.
set -euo pipefail

STAGED_THEME="$HOME/.cache/linuc/sddm-theme.conf.user"
CURRENT_WALL="$HOME/.config/hypr/wallpapers/current.jpg"
NAME_FILE="$HOME/.config/linuc-scripts/.sddm-theme-name"

if [ -f "$NAME_FILE" ]; then
  SDDM_THEME_NAME="$(cat "$NAME_FILE")"
else
  SDDM_THEME_NAME="$(find /usr/share/sddm/themes -maxdepth 1 -iname '*sugar*candy*' -type d -printf '%f\n' 2>/dev/null | head -1)"
  SDDM_THEME_NAME="${SDDM_THEME_NAME:-Sugar-Candy}"
fi
SDDM_THEME_DIR="/usr/share/sddm/themes/$SDDM_THEME_NAME"

if [ ! -f "$STAGED_THEME" ]; then
  echo "Nenhuma paleta gerada ainda pelo matugen — usando as cores padrão da dotfile."
  REPO_FALLBACK="$(dirname "$(readlink -f "$0")")/sddm-theme-default.conf.user"
  if [ -f "$REPO_FALLBACK" ]; then
    mkdir -p "$(dirname "$STAGED_THEME")"
    cp "$REPO_FALLBACK" "$STAGED_THEME"
  else
    echo "Não achei um theme.conf.user de fallback. Rode o matugen-wallpaper.sh com algum wallpaper primeiro."
    exit 1
  fi
fi

if [ ! -d "$SDDM_THEME_DIR" ]; then
  echo "Tema $SDDM_THEME_NAME não encontrado em $SDDM_THEME_DIR."
  echo "Instale com: yay -S sddm-theme-sugar-candy-git"
  exit 1
fi

sudo install -Dm644 "$CURRENT_WALL" /usr/share/backgrounds/linuc-current.jpg
sudo install -Dm644 "$STAGED_THEME" "$SDDM_THEME_DIR/theme.conf.user"

echo "Tema do SDDM sincronizado com o wallpaper e a paleta atual."
