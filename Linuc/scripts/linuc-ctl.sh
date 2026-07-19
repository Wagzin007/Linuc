#!/usr/bin/env bash
# ~/.config/linuc-scripts/linuc-ctl.sh
# Painel de controle da dotfile Linuc — SUPER+C abre isso.
set -uo pipefail

SCRIPTS="$HOME/.config/linuc-scripts"

banner() {
  printf "\033[1;38;2;168;199;250m"
  printf "  ╭──────────────────────────────────────────╮\n"
  printf "  │          Linuc — Painel de Controle       │\n"
  printf "  ╰──────────────────────────────────────────╯\033[0m\n\n"
}

pause() { echo; read -n 1 -s -r -p "Pressione qualquer tecla pra voltar ao menu..."; }

while true; do
  clear
  banner

  choice=$(printf '%s\n' \
    "🖼  Trocar wallpaper" \
    "🎨  Reaplicar cores do wallpaper atual" \
    "🔐  Sincronizar tema do SDDM (login)" \
    "⌨️  Ver atalhos de teclado" \
    "🔄  Recarregar Hyprland" \
    "📊  Reiniciar a waybar" \
    "🖥️  Ver GPU/driver detectado" \
    "🎛️  Abrir qt5ct (tema das apps Qt)" \
    "🎛️  Abrir Kvantum Manager" \
    "📦  Atualizar o sistema (pacman + AUR)" \
    "📝  Editar hyprland.lua" \
    "📝  Editar binds.lua (atalhos)" \
    "❌  Sair" |
    fzf --height=100% --layout=reverse --border \
        --prompt="O que você quer fazer? > " \
        --header="Linuc dotfiles — SUPER+C" \
        --no-info)

  case "$choice" in
    *"Trocar wallpaper"*)
      bash "$SCRIPTS/wallpaper-picker.sh"
      ;;
    *"Reaplicar cores"*)
      CUR="$(readlink -f "$HOME/.config/hypr/wallpapers/current.jpg" 2>/dev/null)"
      if [ -n "$CUR" ]; then
        bash "$SCRIPTS/matugen-wallpaper.sh" "$CUR"
      else
        echo "Nenhum wallpaper aplicado ainda."
      fi
      pause
      ;;
    *"Sincronizar tema do SDDM"*)
      bash "$SCRIPTS/sync-sddm-theme.sh"
      pause
      ;;
    *"Ver atalhos"*)
      bash "$SCRIPTS/show-keybinds.sh"
      ;;
    *"Recarregar Hyprland"*)
      hyprctl reload && echo "Hyprland recarregado."
      pause
      ;;
    *"Reiniciar a waybar"*)
      pkill waybar 2>/dev/null
      sleep 0.3
      waybar >/dev/null 2>&1 &
      disown
      echo "Waybar reiniciada."
      pause
      ;;
    *"GPU/driver"*)
      echo "--- lspci ---"
      lspci -k | grep -EA3 'VGA|3D|Display'
      echo
      echo "--- ~/.config/hypr/gpu.lua ---"
      cat "$HOME/.config/hypr/gpu.lua" 2>/dev/null || echo "(não encontrado)"
      pause
      ;;
    *"qt5ct"*)
      qt5ct >/dev/null 2>&1 &
      disown
      ;;
    *"Kvantum Manager"*)
      kvantummanager >/dev/null 2>&1 &
      disown
      ;;
    *"Atualizar o sistema"*)
      sudo pacman -Syu
      command -v yay >/dev/null 2>&1 && yay -Syu
      pause
      ;;
    *"Editar hyprland.lua"*)
      "${EDITOR:-nano}" "$HOME/.config/hypr/hyprland.lua"
      ;;
    *"Editar binds.lua"*)
      "${EDITOR:-nano}" "$HOME/.config/hypr/binds.lua"
      ;;
    *"Sair"*|"")
      exit 0
      ;;
  esac
done
