#!/usr/bin/env bash
# ============================================================
#  Linuc — instalador de dotfiles Hyprland (Material You)
#  EXCLUSIVO para Arch Linux. Não roda em outras distros.
# ============================================================
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

log()  { echo -e "\033[1;36m[Linuc]\033[0m $1"; }
warn() { echo -e "\033[1;33m[Linuc][atenção]\033[0m $1"; }
err()  { echo -e "\033[1;31m[Linuc][erro]\033[0m $1"; exit 1; }

# --- 0. Garantir que é Arch Linux ---
if ! grep -qi "arch" /etc/os-release 2>/dev/null; then
  err "Este instalador só é compatível com Arch Linux."
fi

if [ "$EUID" -eq 0 ]; then
  err "Não rode como root. O script usa sudo quando precisa."
fi

command -v sudo >/dev/null || err "sudo não encontrado. Instale antes de continuar."

log "Atualizando o sistema..."
sudo pacman -Syu --noconfirm

# --- 1. AUR helper (yay) ---
if ! command -v yay >/dev/null 2>&1; then
  log "Instalando yay (AUR helper)..."
  sudo pacman -S --noconfirm --needed base-devel git
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

# --- 2. Detecção de GPU e correção de drivers faltando ---
# A ISO oficial do Arch já traz mesa/intel/amdgpu, mas garantimos aqui
# caso o usuário tenha feito instalação mínima manual sem eles.
log "Verificando drivers de GPU..."
GPU_INFO="$(lspci | grep -Ei 'vga|3d|display' || true)"

pkgs_gpu=()
if echo "$GPU_INFO" | grep -qi intel; then
  pkgs_gpu+=(mesa vulkan-intel intel-media-driver libva-intel-driver)
fi
if echo "$GPU_INFO" | grep -qi amd; then
  pkgs_gpu+=(mesa vulkan-radeon libva-mesa-driver xf86-video-amdgpu)
fi
if echo "$GPU_INFO" | grep -qi nvidia; then
  warn "GPU NVIDIA detectada. Hyprland não tem suporte oficial NVIDIA;"
  warn "instalando nvidia-open + parâmetros necessários (pode exigir ajustes manuais)."
  pkgs_gpu+=(nvidia-open nvidia-utils egl-wayland lib32-nvidia-utils)
fi

if [ "${#pkgs_gpu[@]}" -gt 0 ]; then
  sudo pacman -S --noconfirm --needed "${pkgs_gpu[@]}"
else
  warn "Nenhuma GPU reconhecida automaticamente; pulando pacotes de driver."
fi

# --- 3. Pacotes base do sistema (Hyprland + Wayland + XWayland compat) ---
log "Instalando pacotes base (Hyprland, portais, áudio, Wayland/X11 compat)..."
sudo pacman -S --noconfirm --needed \
  hyprland xorg-xwayland \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  qt5-wayland qt6-wayland \
  pipewire pipewire-pulse pipewire-alsa wireplumber \
  polkit-kde-agent \
  networkmanager network-manager-applet \
  bluez bluez-utils blueman \
  brightnessctl playerctl \
  grim slurp wl-clipboard cliphist hyprpicker \
  kdeconnect \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji ttf-roboto \
  sddm \
  zsh git base-devel kitty pciutils \
  unzip zip p7zip tar xz lrzip lzop cpio

# --- 3b. Suporte a preview/thumbnails do Dolphin (fotos, vídeos, docs) ---
log "Instalando thumbnailers pro Dolphin (preview de fotos/vídeos sem abrir)..."
sudo pacman -S --noconfirm --needed \
  kimageformats kdegraphics-thumbnailers ffmpegthumbs \
  qt6-imageformats kio-extras

# --- 4. Apps pré-instalados exigidos ---
log "Instalando apps: Firefox, Dolphin, btop, GIMP, OBS, Kdenlive..."
sudo pacman -S --noconfirm --needed \
  firefox \
  dolphin dolphin-plugins ark \
  btop \
  waybar dunst \
  qt5ct qt6ct kvantum kvantum-qt5 \
  gamemode \
  zram-generator \
  gimp obs-studio kdenlive

# --- 5. Pacotes AUR (launcher, matugen, temas Material You, unrar) ---
log "Instalando pacotes AUR (walker, matugen, tema kvantum Material You, sddm theme, unrar)..."
yay -S --noconfirm --needed \
  walker-bin \
  matugen-bin \
  kvantum-theme-materialyou-git \
  sddm-theme-sugar-candy-git \
  fastfetch \
  wlogout \
  zsh-autosuggestions zsh-syntax-highlighting \
  unrar

# --- 6. Copiar dotfiles ---
log "Copiando configs pra ~/.config..."
mkdir -p "$CONFIG_DIR"
for dir in hypr waybar kitty walker qt5ct kvantum matugen fastfetch; do
  rm -rf "$CONFIG_DIR/$dir"
  cp -r "$DOTS_DIR/$dir" "$CONFIG_DIR/$dir"
done

mkdir -p "$CONFIG_DIR/dolphin"
cp "$DOTS_DIR/dolphin/dolphinrc" "$CONFIG_DIR/dolphin/dolphinrc"

cp "$DOTS_DIR/zsh/.zshrc" "$HOME/.zshrc"

# wallpaper padrão
mkdir -p "$CONFIG_DIR/hypr/wallpapers"
if [ -f "$DOTS_DIR/wallpapers/default.jpg" ]; then
  cp "$DOTS_DIR/wallpapers/default.jpg" "$CONFIG_DIR/hypr/wallpapers/current.jpg"
fi

mkdir -p "$CONFIG_DIR/linuc-scripts"
shopt -s nullglob
for script in "$DOTS_DIR"/scripts/*.sh; do
  chmod +x "$script"
  cp "$script" "$CONFIG_DIR/linuc-scripts/"
done
shopt -u nullglob

# --- 7. zram e gamemode ---
log "Configurando zram..."
if [ -f "$DOTS_DIR/scripts/setup-zram.sh" ]; then
  bash "$DOTS_DIR/scripts/setup-zram.sh"
else
  warn "setup-zram.sh não encontrado; pulando."
fi

log "Configurando gamemode..."
if [ -f "$DOTS_DIR/scripts/setup-gamemode.sh" ]; then
  bash "$DOTS_DIR/scripts/setup-gamemode.sh"
else
  warn "setup-gamemode.sh não encontrado; pulando."
fi

# --- 8. Gerar paleta Material You inicial ---
if [ -f "$CONFIG_DIR/hypr/wallpapers/current.jpg" ]; then
  log "Gerando paleta Material You a partir do wallpaper padrão..."

  if [ -f "$DOTS_DIR/scripts/matugen-wallpaper.sh" ]; then
    bash "$DOTS_DIR/scripts/matugen-wallpaper.sh" \
      "$CONFIG_DIR/hypr/wallpapers/current.jpg" || \
      warn "matugen falhou, rode manualmente depois com um wallpaper."
  else
    warn "matugen-wallpaper.sh não encontrado; pulando."
  fi

else
  warn "Wallpaper padrão não encontrado; pulando geração da paleta."
fi

# --- 9. SDDM ---
log "Habilitando SDDM..."
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=sugar-candy
EOF
sudo systemctl enable sddm.service

# --- 10. Shell padrão ---
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" "$USER" || warn "Não consegui trocar o shell padrão automaticamente; rode 'chsh -s $(command -v zsh)'."
fi

log "Instalação concluída! Reinicie o sistema e selecione a sessão Hyprland no SDDM."
log "Pra trocar o wallpaper e regenerar a paleta Material You depois:"
log "  ~/.config/linuc-scripts/matugen-wallpaper.sh /caminho/da/imagem.jpg"
