#!/usr/bin/env bash
# ============================================================
#  Linuc — instalador de dotfiles Hyprland (Material You)
#  EXCLUSIVO para Arch Linux. Não roda em outras distros.
# ============================================================
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

log()  { echo -e "\033[1;36m[Linuc]\033[0m $1" >&2; }
warn() { echo -e "\033[1;33m[Linuc][atenção]\033[0m $1" >&2; }
err()  { echo -e "\033[1;31m[Linuc][erro]\033[0m $1" >&2; exit 1; }

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

AMD_LEGACY=false
if echo "$GPU_INFO" | grep -qi amd; then
  # Placas AMD anteriores à GCN (pré-2012, ex: TeraScale/RV7xx/Evergreen) usam
  # o driver kernel legado 'radeon', não o 'amdgpu' moderno, e NÃO têm Vulkan.
  # Detectar isso corretamente evita instalar vulkan-radeon (que não funciona
  # nelas) e avisa que a placa é o gargalo real, não a config.
  if lspci -k | grep -A3 -iE 'vga|3d|display' | grep -qi "Kernel driver in use: radeon$"; then
    AMD_LEGACY=true
    warn "GPU AMD pré-GCN detectada (driver kernel legado 'radeon', sem Vulkan)."
    warn "Hyprland (Wayland) tem suporte limitado nesse tipo de placa; renderização"
    warn "por software será usada por padrão pra garantir estabilidade."
    pkgs_gpu+=(mesa xf86-video-ati libva-mesa-driver)
  else
    pkgs_gpu+=(mesa vulkan-radeon libva-mesa-driver xf86-video-amdgpu)
  fi
fi
if echo "$GPU_INFO" | grep -qi nvidia; then
  warn "GPU NVIDIA detectada. Hyprland não tem suporte oficial NVIDIA;"
  warn "instalando driver + parâmetros necessários (pode exigir ajustes manuais)."

  # Kernel != linux padrão (zen/lts/hardened) precisa da variante DKMS,
  # já que os pacotes nvidia-open/nvidia normais são pré-compilados só pro kernel stock.
  KREL="$(uname -r)"
  if [[ "$KREL" == *-zen* || "$KREL" == *-lts* || "$KREL" == *-hardened* ]]; then
    log "Kernel não-padrão detectado ($KREL) — usando nvidia-open-dkms."
    HEADER_PKG="linux-zen-headers"
    [[ "$KREL" == *-lts* ]] && HEADER_PKG="linux-lts-headers"
    [[ "$KREL" == *-hardened* ]] && HEADER_PKG="linux-hardened-headers"
    pkgs_gpu+=("$HEADER_PKG" nvidia-open-dkms nvidia-utils egl-wayland lib32-nvidia-utils)
  else
    pkgs_gpu+=(nvidia-open nvidia-utils egl-wayland lib32-nvidia-utils)
  fi
fi

if [ "${#pkgs_gpu[@]}" -gt 0 ]; then
  sudo pacman -S --noconfirm --needed "${pkgs_gpu[@]}"
else
  warn "Nenhuma GPU reconhecida automaticamente; pulando pacotes de driver."
fi

# --- 2b. Gera hypr/gpu.lua com as env vars corretas pra essa GPU/ambiente ---
# É isso que resolve apps (kitty, a janela do SUPER+H) não abrindo por causa
# de aceleração de hardware mal configurada — Hyprland/kitty precisam de EGL
# funcional, e VMs ou drivers errados quebram isso silenciosamente.
log "Gerando hypr/gpu.lua de acordo com a GPU/ambiente detectado..."
VIRT="$(systemd-detect-virt 2>/dev/null || echo none)"
GPU_LUA="$DOTS_DIR/hypr/gpu.lua"

{
  echo "-- ~/.config/hypr/gpu.lua"
  echo "-- Gerado automaticamente pelo install.sh em $(date +%F)."
  echo "-- GPU detectada: ${GPU_INFO:-nenhuma}  |  Virtualização: $VIRT"
  echo

  if [ "$VIRT" != "none" ] && [ -n "$VIRT" ]; then
    warn "Rodando dentro de uma VM ($VIRT) — forçando renderização por software."
    echo 'hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")'
    echo 'hl.env("LIBGL_ALWAYS_SOFTWARE", "1")'
    echo 'hl.env("WLR_NO_HARDWARE_CURSORS", "1")'
  elif [ "$AMD_LEGACY" = true ]; then
    echo 'hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")'
    echo 'hl.env("LIBGL_ALWAYS_SOFTWARE", "1")'
    echo 'hl.env("WLR_NO_HARDWARE_CURSORS", "1")'
  elif echo "$GPU_INFO" | grep -qi nvidia; then
    echo 'hl.env("WLR_NO_HARDWARE_CURSORS", "1")'
    echo 'hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")'
    echo 'hl.env("LIBVA_DRIVER_NAME", "nvidia")'
    echo 'hl.env("GBM_BACKEND", "nvidia-drm")'
    echo 'hl.env("__GL_GSYNC_ALLOWED", "0")'
    echo 'hl.env("__GL_VRR_ALLOWED", "0")'
  elif echo "$GPU_INFO" | grep -qi intel; then
    echo 'hl.env("LIBVA_DRIVER_NAME", "iHD")'
    echo 'hl.env("WLR_NO_HARDWARE_CURSORS", "0")'
  elif echo "$GPU_INFO" | grep -qi amd; then
    echo 'hl.env("LIBVA_DRIVER_NAME", "radeonsi")'
    echo 'hl.env("WLR_NO_HARDWARE_CURSORS", "0")'
  else
    warn "GPU não identificada — usando fallback seguro (renderização por software)."
    echo 'hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")'
    echo 'hl.env("LIBGL_ALWAYS_SOFTWARE", "1")'
  fi
} > "$GPU_LUA"

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
  brightnessctl playerctl pavucontrol \
  grim slurp wl-clipboard cliphist hyprpicker \
  hyprlock hypridle hyprpaper \
  jq libnotify glib2 gsettings-desktop-schemas \
  kdeconnect \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji ttf-roboto \
  sddm \
  zsh git base-devel \
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
  materia-gtk-theme kvantum-theme-materia \
  gamemode \
  zram-generator \
  gimp obs-studio kdenlive \
  zoxide eza fzf bat ripgrep fd

# --- 5. Pacotes AUR (launcher/elephant, matugen, tema SDDM) ---
# Remove pacotes de tentativas antigas que conflitam com os nomes atuais
for stale in walker-bin walker-git; do
  if pacman -Qq "$stale" &>/dev/null; then
    warn "Removendo '$stale' (conflita com o pacote 'walker' atual)..."
    sudo pacman -R --noconfirm "$stale"
  fi
done

log "Instalando pacotes AUR (elephant + provedores do walker, matugen, tema SDDM, unrar)..."
yay -S --noconfirm --needed \
  walker \
  matugen-bin \
  sddm-theme-sugar-candy-git \
  fastfetch \
  wlogout \
  zsh-autosuggestions zsh-syntax-highlighting \
  unrar \
  elephant elephant-desktopapplications elephant-calc elephant-files \
  elephant-runner elephant-symbols elephant-websearch elephant-clipboard \
  elephant-archlinuxpkgs elephant-unicode elephant-providerlist \
  hyprshot

# --- 6. Copiar dotfiles (nunca aborta se algo faltar, só avisa) ---
log "Copiando configs pra ~/.config..."
mkdir -p "$CONFIG_DIR"
for dir in hypr waybar kitty walker qt5ct kvantum matugen fastfetch dunst; do
  if [ -d "$DOTS_DIR/$dir" ]; then
    rm -rf "$CONFIG_DIR/$dir"
    cp -r "$DOTS_DIR/$dir" "$CONFIG_DIR/$dir"
  else
    warn "Pasta '$dir' não encontrada no repo, pulando."
  fi
done

if [ -f "$DOTS_DIR/dolphin/dolphinrc" ]; then
  mkdir -p "$CONFIG_DIR"
  cp "$DOTS_DIR/dolphin/dolphinrc" "$CONFIG_DIR/dolphinrc"
else
  warn "dolphinrc não encontrado, pulando config do Dolphin."
fi

if [ -f "$DOTS_DIR/zsh/.zshrc" ]; then
  cp "$DOTS_DIR/zsh/.zshrc" "$HOME/.zshrc"
else
  warn ".zshrc não encontrado em $DOTS_DIR/zsh/, pulando (zsh vai usar o padrão)."
fi

# wallpaper padrão
mkdir -p "$CONFIG_DIR/hypr/wallpapers"
mkdir -p "$HOME/Imagens/Wallpapers"
if [ -f "$DOTS_DIR/wallpapers/default.jpg" ]; then
  cp "$DOTS_DIR/wallpapers/default.jpg" "$CONFIG_DIR/hypr/wallpapers/current.jpg"
  cp "$DOTS_DIR/wallpapers/default.jpg" "$HOME/Imagens/Wallpapers/default.jpg"
else
  warn "Wallpaper padrão não encontrado; coloque imagens em ~/Imagens/Wallpapers e use SUPER+W."
fi

if [ -d "$DOTS_DIR/scripts" ]; then
  chmod +x "$DOTS_DIR/scripts/"*.sh 2>/dev/null || true
  mkdir -p "$CONFIG_DIR/linuc-scripts"
  cp "$DOTS_DIR/scripts/"*.sh "$CONFIG_DIR/linuc-scripts/" 2>/dev/null || true
  cp "$DOTS_DIR/scripts/"*.conf.user "$CONFIG_DIR/linuc-scripts/" 2>/dev/null || true
fi

# --- 7. Pastas padrão do usuário (Download, Imagens, Documentos, etc) ---
log "Criando pastas padrão em $HOME (Download, Imagens, Documentos, Vídeos, Música, Área de trabalho, Público)..."
sudo pacman -S --noconfirm --needed xdg-user-dirs
LANG=pt_BR.UTF-8 xdg-user-dirs-update 2>/dev/null || xdg-user-dirs-update
mkdir -p "$HOME/Download" "$HOME/Imagens" "$HOME/Documentos" "$HOME/Vídeos" "$HOME/Música" "$HOME/Área de trabalho" "$HOME/Público"

# --- 8. Corrige o menu "Abrir com" do Dolphin (banco XDG ausente em instalações minimalistas) ---
log "Corrigindo banco XDG pro menu 'Abrir com' do Dolphin..."
yay -S --noconfirm --needed archlinux-xdg-menu
sudo mkdir -p /etc/xdg/menus
if [ -f /etc/xdg/menus/arch-applications.menu ] && [ ! -e /etc/xdg/menus/applications.menu ]; then
  sudo ln -sf /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu
fi
XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental 2>/dev/null || \
  warn "kbuildsycoca6 não encontrado agora; ele roda de novo no primeiro login do Dolphin."

# --- 9. zram e gamemode ---
log "Configurando zram..."
[ -f "$DOTS_DIR/scripts/setup-zram.sh" ] && bash "$DOTS_DIR/scripts/setup-zram.sh" || warn "setup-zram.sh não encontrado, pulando."

log "Configurando gamemode..."
[ -f "$DOTS_DIR/scripts/setup-gamemode.sh" ] && bash "$DOTS_DIR/scripts/setup-gamemode.sh" || warn "setup-gamemode.sh não encontrado, pulando."

# --- 10. Gerar paleta Material You inicial ---
if [ -f "$CONFIG_DIR/hypr/wallpapers/current.jpg" ] && [ -f "$DOTS_DIR/scripts/matugen-wallpaper.sh" ]; then
  log "Gerando paleta Material You a partir do wallpaper padrão..."
  bash "$DOTS_DIR/scripts/matugen-wallpaper.sh" "$CONFIG_DIR/hypr/wallpapers/current.jpg" || \
    warn "matugen falhou, rode manualmente depois com um wallpaper."
fi

# --- 11. SDDM (Material You também no login) ---
log "Habilitando SDDM..."
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=sugar-candy
EOF
sudo systemctl enable sddm.service

log "Aplicando o Material You na tela de login..."
if [ -f "$CONFIG_DIR/linuc-scripts/sync-sddm-theme.sh" ]; then
  bash "$CONFIG_DIR/linuc-scripts/sync-sddm-theme.sh" || \
    warn "Não deu pra sincronizar o tema do SDDM agora; rode ~/.config/linuc-scripts/sync-sddm-theme.sh manualmente depois."
else
  warn "sync-sddm-theme.sh não encontrado, pulando tema do SDDM."
fi

# --- 12. Shell padrão ---
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" "$USER" || warn "Não consegui trocar o shell padrão automaticamente; rode 'chsh -s $(command -v zsh)'."
fi

log "Instalação concluída! Reinicie o sistema e selecione a sessão Hyprland no SDDM."
log "Pra trocar o wallpaper e regenerar a paleta Material You depois:"
log "  ~/.config/linuc-scripts/matugen-wallpaper.sh /caminho/da/imagem.jpg"
