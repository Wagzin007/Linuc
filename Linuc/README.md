# Linuc — dotfiles Arch Linux + Hyprland (Material You)

Dotfiles exclusivas pra **Arch Linux** com **Hyprland** (Wayland), com compatibilidade
total pra apps X11 via XWayland, tema **Material You** dinâmico (gerado do wallpaper
via `matugen`), foco em leveza (baixo consumo de RAM) e fluidez sem efeitos pesados.

## Stack

| Categoria        | Ferramenta |
|-------------------|------------|
| Compositor        | Hyprland (config em Lua, ≥0.55) |
| Barra              | Waybar (com tray p/ apps em segundo plano) |
| Launcher           | Walker (Wayland nativo, leve) |
| Terminal           | kitty + zsh (zinit, powerlevel10k) |
| Logo/specs no shell| fastfetch (autostart no `.zshrc`) |
| Gerenciador de arquivos | Dolphin (kio-extras, previews de foto/vídeo, extração universal) |
| Color picker       | hyprpicker (`SUPER+SHIFT+C`) |
| Edição/gravação    | GIMP, OBS Studio, Kdenlive |
| Integração celular | KDE Connect |
| Tema Qt           | qt5ct/qt6ct + Kvantum |
| Cor dinâmica       | matugen (Material You a partir do wallpaper) |
| Login manager      | SDDM (tema Sugar Candy) |
| AUR helper         | yay |
| Performance        | zram-generator (zstd) + gamemode |

## Instalação

> **Atenção:** o `install.sh` roda **só em Arch Linux**. Ele valida o `/etc/os-release`
> e aborta em qualquer outra distro.

```bash
git clone https://github.com/Wagzin007/Linuc.git
cd Linuc
chmod +x install.sh
./install.sh
```

O instalador:

1. Roda `sudo pacman -Syu` primeiro, e só então instala o **yay** (AUR helper),
   caso ainda não exista.
2. Detecta a GPU (Intel/AMD/NVIDIA) via `lspci` e instala os drivers que
   estiverem faltando — cobre o caso de a ISO do Arch ter sido instalada
   de forma mínima sem os pacotes gráficos.
3. Instala Hyprland, XWayland, portais, áudio (pipewire), Bluetooth,
   fontes Nerd Font, SDDM, hyprpicker (color picker) e KDE Connect.
4. Instala thumbnailers do Dolphin (`kimageformats`, `kdegraphics-thumbnailers`,
   `ffmpegthumbs`) pra preview de fotos/vídeos direto na listagem, sem abrir o arquivo.
5. Instala os apps pedidos: Firefox, Dolphin (+plugins), btop, GIMP, OBS Studio,
   Kdenlive, qt5ct/kvantum, gamemode.
6. Instala pacotes de compactação (zip, p7zip, tar, xz, lrzip, lzop, cpio e
   `unrar` via AUR) pro Dolphin/Ark abrirem qualquer formato — zip, rar, tar.gz,
   7z etc — sem travar.
7. Instala via AUR: walker, matugen, tema Kvantum Material You, tema SDDM,
   fastfetch.
8. Copia as configs pra `~/.config/`.
9. Configura **zram** (swap comprimido em RAM, zstd, sem tocar disco) e
   **gamemode** (daemon de performance pra jogos) automaticamente.
10. Gera a paleta Material You inicial a partir do wallpaper padrão.
11. Habilita o SDDM como display manager.

Depois: reinicie e selecione a sessão **Hyprland** na tela de login.

## Atalhos

Aperte `SUPER + H` a qualquer momento pra abrir uma janelinha flutuante com a
lista completa de atalhos da dotfile e uma descrição curta de cada um
(script em `scripts/show-keybinds.sh`, copiado pra `~/.config/linuc-scripts/`).

## Trocar de wallpaper (e a paleta Material You junto)

```bash
~/.config/linuc-scripts/matugen-wallpaper.sh /caminho/da/imagem.jpg
```

Isso regenera automaticamente as cores do Hyprland, waybar, kitty e GTK,
e recarrega tudo (`hyprctl reload` + `waybar` reload) sem precisar deslogar.

## Estrutura

```
Linuc/
├── install.sh              # instalador (Arch-only)
├── hypr/                   # hyprland.lua, binds, window rules, hypridle/hyprlock/hyprpaper
├── waybar/                 # config.jsonc + style.css (Material You)
├── kitty/                  # kitty.conf + colors.conf (gerado pelo matugen)
├── zsh/.zshrc               # zsh + fastfetch no boot do terminal
├── fastfetch/config.jsonc   # logo + specs do sistema
├── walker/                 # launcher (config.toml + style.css)
├── qt5ct/ kvantum/           # tema Qt unificado com o resto
├── dolphin/dolphinrc         # gerenciador de arquivos configurado
├── matugen/                 # config + templates pra Material You dinâmico
└── scripts/
    ├── setup-zram.sh
    ├── setup-gamemode.sh
    └── matugen-wallpaper.sh
```

## Notas de performance

- `vfr = true` e sem `disable_splash_rendering`/logo: menos overhead parado.
- Blur leve (`size = 4`, `passes = 2`) em vez de blur pesado.
- zram evita gravação em disco pra swap, reduzindo desgaste de SSD e latência.
- gamemode aplica prioridade de CPU/renice automaticamente ao rodar jogos
  (via `gamemoderun %command%` no Steam/Lutris/Heroic).
