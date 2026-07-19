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
    ["col.active_border"] = colors.primary,
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
      matu = hl.curve("matu", {
        type = "bezier",
        points = {
          {0.2, 0.0},
          {0.0, 1.0},
        }
      }),
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

--  gestures = {
--    workspace_swipe = true,
--    workspace_swipe_fingers = 3,
--  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    vrr = 1,
    force_default_wallpaper = 0,
  },

  dwindle = {
    preserve_split = true,
  },

  xwayland = {
    force_zero_scaling = true, -- evita apps X11 borrados em telas HiDPI
  },
})

-- Monitor: ajusta automaticamente, "responsivo com qualquer tela"

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

hl.on("hyprland.start", function()

hl.exec_cmd("hyprpaper")
hl.exec_cmd("hypridle")
hl.exec_cmd("waybar")
hl.exec_cmd("dunst")
hl.exec_cmd("nm-applet --indicator")
hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
hl.exec_cmd("wl-paste --watch cliphist store")
hl.exec_cmd("kdeconnect-indicator")
hl.exec_cmd("systemctl --user start hyprpolkitagent 2>/dev/null")
hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'MaterialYou'")

end)

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
