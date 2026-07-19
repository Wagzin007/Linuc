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
   de forma mínima sem os pacotes gráficos. Também detecta kernels
   não-padrão (`zen`, `lts`, `hardened`) e troca automaticamente pra
   variante `-dkms` do driver NVIDIA quando necessário.
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
8. Copia as configs pra `~/.config/` — cada cópia é condicional (`if [ -f ... ]`);
   se algum arquivo estiver faltando no repo, o instalador **avisa e continua**,
   nunca aborta a instalação por causa disso.
9. Cria as pastas padrão em `~/` (Download, Imagens, Documentos, Vídeos, Música,
   Área de trabalho, Público) via `xdg-user-dirs-update`.
10. Corrige o menu **"Abrir com"** do Dolphin, que fica em branco em instalações
    Hyprland sem o Plasma completo: instala `archlinux-xdg-menu`, cria o link
    simbólico de `applications.menu` e reconstrói o banco com `kbuildsycoca6`.
11. Configura **zram** (swap comprimido em RAM, zstd, sem tocar disco) e
    **gamemode** (daemon de performance pra jogos) automaticamente.
12. Gera a paleta Material You inicial a partir do wallpaper padrão.
13. Habilita o SDDM como display manager.

## Changelog

**v0.2** — correções feitas após a primeira instalação limpa (ver histórico
completo de bugs no commit correspondente):
- Removido `lib32-gamemode` (pacote inexistente) do installer e do
  `setup-gamemode.sh`.
- Trocado `paru` por `yay` como AUR helper.
- `binds.lua` e `windowrules.lua` reescritos do zero pra API Lua atual do
  Hyprland (`hl.dsp.*`, `hl.window_rule({ match = {...} })`, `hl.bind` com
  string concatenada, autostart via `hl.on("hyprland.start", ...)`).
- `waybar/colors.css` (fallback) agora vai versionado no repo — antes o
  `style.css` dava `@import` num arquivo que só existia depois do matugen
  rodar, e a waybar não subia.
- Corrigido o menu "Abrir com" em branco no Dolphin (banco XDG ausente em
  instalação minimalista sem Plasma).
- Instalador agora cria as pastas padrão do usuário (Download, Imagens etc).
- Todas as cópias de arquivo no installer viraram condicionais — arquivo
  faltando gera aviso, não aborta a instalação.

Depois: reinicie e selecione a sessão **Hyprland** na tela de login.

## Atalhos

Aperte `SUPER + H` a qualquer momento pra abrir uma janelinha flutuante com a
lista completa de atalhos da dotfile e uma descrição curta de cada um
(script em `scripts/show-keybinds.sh`, copiado pra `~/.config/linuc-scripts/`).

## Trocar de wallpaper

**Do jeito fácil:** aperte `SUPER + W`. Abre um seletor com preview das imagens
em tempo real (usando `fzf` + `kitty icat`) direto de `~/Imagens/Wallpapers/`.
Navega com as setas, aperta Enter — aplica o wallpaper e já regenera a paleta
Material You (Hyprland, waybar, kitty, GTK, **dunst** e **hyprlock**) na hora.

Só jogar as imagens novas em `~/Imagens/Wallpapers/` que elas já aparecem no
seletor, não precisa configurar nada.

**Via terminal**, se preferir: (e a paleta Material You junto)

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
