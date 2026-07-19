-- ~/.config/hypr/hyprland.lua
-- Linuc dotfiles — Hyprland core config
-- Escrito contra a API Lua oficial (exemplo: hyprwm/Hyprland/example/hyprland.lua)

require("colors")  -- gerado/atualizado pelo matugen (Material You) em ~/.config/hypr/colors.lua
require("gpu")     -- env vars de renderização, gerado pelo install.sh de acordo com a GPU detectada

------------------
---- MONITORS ----
------------------
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "kitty"
local fileManager = "dolphin"
local browser = "firefox"
local menu = "walker"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("elephant")            -- backend de dados do walker; sem isso o launcher fica travado em "awaiting for elephants"
  hl.exec_cmd("walker --gapplication-service")  -- deixa o walker "quente" em background; SUPER+Space só reabre a janela (instantâneo)
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("waybar")
  hl.exec_cmd("dunst")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("kdeconnect-indicator")
  hl.exec_cmd("qt5ct")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_MENU_PREFIX", "arch-")       -- corrige o menu "Abrir com" do Dolphin sem Plasma completo
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    col = {
      active_border = { colors = { colors.primary, colors.tertiary }, angle = 45 },
      inactive_border = colors.surface_variant,
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 14,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.94,
    shadow = {
      enabled = true,
      range = 12,
      render_power = 2,
      color = 0x801a1a1a,
    },
    blur = {
      enabled = true,
      size = 4,        -- leve, prioriza performance/RAM sobre efeito pesado
      passes = 2,
      vibrancy = 0.15,
    },
  },

  animations = {
    enabled = true,
  },
})

-- curves (Material Design 3 "emphasized" easing)
hl.curve("matu", { type = "bezier", points = { { 0.2, 0.0 }, { 0.0, 1.0 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4.5, bezier = "matu" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.0, bezier = "matu", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "matu", style = "popin 92%" })
hl.animation({ leaf = "border",     enabled = true, speed = 3.0, bezier = "matu" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.0, bezier = "matu" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "matu", style = "slide" })

hl.config({
  dwindle = {
    preserve_split = true,
  },
})

----------------
---- MISC -----
----------------
hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
  },
})

---------------
---- INPUT ----
---------------
hl.config({
  input = {
    kb_layout = "br",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = { natural_scroll = true },
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

require("binds")
require("windowrules")
