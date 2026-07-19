#!/usr/bin/env bash
# ~/.config/linuc-scripts/show-keybinds.sh
# Abre uma janelinha flutuante com todos os atalhos da dotfile (SUPER+H).
set -euo pipefail

C_TITLE="\033[1;38;2;168;199;250m"   # azul Material You (primary)
C_KEY="\033[1;38;2;221;188;224m"     # tertiary
C_DESC="\033[0;38;2;226;226;230m"    # on-surface
C_RESET="\033[0m"

print_row() {
  printf "  ${C_KEY}%-22s${C_RESET} ${C_DESC}%s${C_RESET}\n" "$1" "$2"
}

clear
printf "${C_TITLE}\n"
printf "  ╭──────────────────────────────────────────╮\n"
printf "  │            Linuc — Atalhos                │\n"
printf "  ╰──────────────────────────────────────────╯${C_RESET}\n\n"

printf "${C_TITLE}  Geral${C_RESET}\n"
print_row "SUPER + Return"   "Abre o terminal (kitty)"
print_row "SUPER + Q"        "Fecha a janela ativa"
print_row "SUPER + E"        "Abre o gerenciador de arquivos (Dolphin)"
print_row "SUPER + B"        "Abre o Firefox"
print_row "SUPER + Space"    "Abre o launcher de apps (Walker)"
print_row "SUPER + T"        "Abre o btop num terminal"
print_row "SUPER + H"        "Mostra esta janela de atalhos"
print_row "SUPER + W"        "Escolhe/troca o wallpaper (com preview)"
print_row "SUPER + SHIFT+Q"  "Sai do Hyprland"
echo

printf "${C_TITLE}  Janelas${C_RESET}\n"
print_row "SUPER + V"        "Alterna janela flutuante/tiled"
print_row "SUPER + F"        "Tela cheia"
print_row "SUPER + P"        "Modo pseudotile"
print_row "SUPER + J"        "Alterna direção do split"
print_row "SUPER + H/J/K/L"  "Move o foco entre janelas"
print_row "SUPER + botão esq (arrastar)" "Move a janela"
print_row "SUPER + botão dir (arrastar)" "Redimensiona a janela"
echo

printf "${C_TITLE}  Workspaces${C_RESET}\n"
print_row "SUPER + 0-9"        "Vai pro workspace 1-10"
print_row "SUPER + SHIFT+0-9"  "Move a janela pro workspace 1-10"
echo

printf "${C_TITLE}  Utilitários${C_RESET}\n"
print_row "SUPER + L"          "Bloqueia a tela (hyprlock)"
print_row "SUPER + SHIFT+C"    "Color picker (hyprpicker), copia o hex"
print_row "PrintScreen"        "Print de uma área (copia pro clipboard)"
echo

printf "${C_TITLE}  Áudio / Brilho${C_RESET}\n"
print_row "Volume +/-"       "Ajusta volume (5%)"
print_row "Mute"             "Muta/desmuta o áudio"
print_row "Brilho +/-"       "Ajusta o brilho da tela (5%)"
echo

printf "${C_DESC}Pressione qualquer tecla pra fechar...${C_RESET}\n"
read -n 1 -s -r
