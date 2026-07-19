#!/usr/bin/env bash
# ~/.config/linuc-scripts/kitty-safe.sh
# Tenta abrir o kitty normal (acelerado por GPU). Se ele morrer com
# segfault (exit 139) por causa de driver/EGL, reabre forçando
# renderização por software — não trava o usuário sem terminal.
set -uo pipefail

kitty "$@"
code=$?

if [ "$code" -eq 139 ]; then
  notify-send "Linuc" "kitty crashou (driver de GPU). Reabrindo em modo software..." 2>/dev/null || true
  LIBGL_ALWAYS_SOFTWARE=1 kitty "$@"
fi
