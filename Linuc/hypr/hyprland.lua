-- ~/.config/hypr/hyprland.lua
-- Linuc dotfiles — Hyprland core config (Hyprland >= 0.55, sintaxe Lua)

require("colors")     -- gerado/atualizado pelo matugen (Material You) em ~/.config/hypr/colors.lua
require("binds")
require("windowrules")

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    ["col.active_border"]   = colors.primary .. " " .. colors.tertiary .. " 45deg",
    ["col.inactive_border"] = colors.surface_variant,
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = false,
  },

  decoration = {
    rounding = 14,
    active_opacity = 1.0,
    inactive_opacity = 0.94,
    blur = {
      enabled = true,
      size = 4,           -- leve: prioriza performance/RAM sobre efeito pesado
      passes = 2,
      new_optimizations = true,
      ignore_opacity = true,
    },
    shadow = {
      enabled = true,
      range = 12,
      render_power = 2,
      color = colors.shadow,
    },
  },

  animations = {
    enabled = true,
    curve = {
      matu = hl.curve(0.2, 0.0, 0.0, 1.0), -- easing "emphasized" do Material Design 3
    },
    animation = {
      { "windows",   true, "0.18", "matu" },
      { "windowsOut", true, "0.16", "matu", "popin 92%" },
      { "border",    true, "0.15", "matu" },
      { "fade",      true, "0.12", "matu" },
      { "workspaces", true, "0.20", "matu", "slide" },
    },
  },

  input = {
    kb_layout = "br",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = { natural_scroll = true },
  },

  gestures = {
    workspace_swipe = true,
    workspace_swipe_fingers = 3,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    vfr = true,              -- variable frame rate: economiza CPU/RAM parado
    vrr = 1,
    force_default_wallpaper = 0,
  },

  dwindle = {
    pseudotile = true,
    preserve_split = true,
  },

  xwayland = {
    force_zero_scaling = true, -- evita apps X11 borrados em telas HiDPI
  },
})

-- Monitor: ajusta automaticamente, "responsivo com qualquer tela"
hl.monitor("", "preferred", "auto", 1)

-- Autostart
hl.exec_once("hyprpaper")
hl.exec_once("hypridle")
hl.exec_once("waybar")
hl.exec_once("dunst")
hl.exec_once("nm-applet --indicator")
hl.exec_once("/usr/lib/polkit-kde-authentication-agent-1")
hl.exec_once("wl-paste --watch cliphist store")
hl.exec_once("kdeconnect-indicator")
hl.exec_once("qt5ct")           -- garante QT_QPA_PLATFORMTHEME lido
hl.exec_once("systemctl --user start hyprpolkitagent 2>/dev/null")
hl.exec_once("gsettings set org.gnome.desktop.interface gtk-theme 'MaterialYou'")

-- Variáveis de ambiente essenciais p/ compat X11/Wayland + Qt/GTK
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
