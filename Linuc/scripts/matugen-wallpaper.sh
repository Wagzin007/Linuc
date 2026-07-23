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

# Se rodando num terminal de verdade (ex.: SUPER+W abre um kitty
# interativo), deixa o matugen mostrar o prompt de escolha da cor
# predominante -- é um recurso útil, não um bug. Só força a cor mais
# dominante (index 0) automaticamente quando NÃO há terminal interativo
# (chamada automatizada/headless), pra não travar nesse caso.
if [ -t 0 ] && [ -t 1 ]; then
  matugen image "$NEW_REAL" --mode dark --type scheme-tonal-spot
else
  matugen image "$NEW_REAL" --mode dark --type scheme-tonal-spot --source-color-index 0
fi

# --- Aplica o wallpaper no hyprpaper ao vivo -------------------------------
# Estratégia: tenta trocar via IPC (rápido, sem flicker). Verifica se pegou
# de fato. Se não pegou (versão de hyprpaper que não suporta bem a IPC,
# socket não respondendo, etc.), mata e reinicia o hyprpaper -- ele volta a
# ler o hyprpaper.conf padrão, que aponta pro symlink current.jpg, então
# sobe já com a imagem nova (sem cache, processo novo).
wallpaper_applied=false

if command -v hyprctl >/dev/null 2>&1 && pgrep -x hyprpaper >/dev/null 2>&1; then
  hyprctl hyprpaper preload "$NEW_REAL" >/tmp/hyprpaper-preload.err 2>&1 \
    || echo "[matugen-wallpaper] aviso: preload falhou -> $(cat /tmp/hyprpaper-preload.err 2>/dev/null)" >&2

  # Tenta o alvo "todos os monitores" (sintaxe padrão) e também cada monitor
  # nomeado explicitamente, porque algumas versões do hyprpaper não aplicam
  # o alvo vazio em monitores que já tinham uma regra default carregada.
  hyprctl hyprpaper wallpaper ",$NEW_REAL" >/dev/null 2>&1 || true
  if command -v jq >/dev/null 2>&1; then
    while IFS= read -r mon; do
      [ -n "$mon" ] && hyprctl hyprpaper wallpaper "$mon,$NEW_REAL" >/dev/null 2>&1 || true
    done < <(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
  fi

  if [ -n "$OLD_REAL" ] && [ "$OLD_REAL" != "$NEW_REAL" ]; then
    hyprctl hyprpaper unload "$OLD_REAL" >/dev/null 2>&1 || true
  fi

  # Confirma se a textura nova está realmente ativa em algum monitor.
  active="$(hyprctl hyprpaper listactive 2>/dev/null || true)"
  if [ -n "$active" ] && printf '%s' "$active" | grep -qF "$NEW_REAL"; then
    wallpaper_applied=true
  fi
fi

if [ "$wallpaper_applied" = false ]; then
  echo "[matugen-wallpaper] troca ao vivo não confirmada, reiniciando o hyprpaper..." >&2
  pkill -x hyprpaper 2>/dev/null || true
  # dá um tempinho pro processo antigo soltar o socket antes de subir outro
  for _ in 1 2 3 4 5; do
    pgrep -x hyprpaper >/dev/null 2>&1 || break
    sleep 0.2
  done
  hyprctl dispatch exec hyprpaper >/dev/null 2>&1 || true
fi

hyprctl reload
pkill -SIGUSR2 waybar 2>/dev/null || true
command -v dunstctl >/dev/null 2>&1 && dunstctl reload 2>/dev/null || true

if [ "$wallpaper_applied" = true ]; then
  echo "Paleta Material You aplicada a partir de $WALL (wallpaper trocado ao vivo via IPC)"
else
  echo "Paleta Material You aplicada a partir de $WALL (hyprpaper foi reiniciado pra pegar a imagem nova)"
fi
echo "(pra levar essas cores/wallpaper também pra tela de login: ~/.config/linuc-scripts/sync-sddm-theme.sh — pede sudo)"
