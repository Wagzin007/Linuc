-- ~/.config/hypr/windowrules.lua
-- Regras pra apps X11 (XWayland) e utilitários abrirem flutuando/corretos

hl.window_rule({
  name = "float-pavucontrol",
  match = { class = "^(pavucontrol)$" },
  float = true,
})

hl.window_rule({
  name = "float-nm-editor",
  match = { class = "^(nm-connection-editor)$" },
  float = true,
})

hl.window_rule({
  name = "float-blueman",
  match = { class = "^(blueman-manager)$" },
  float = true,
})

hl.window_rule({
  name = "float-kvantummanager",
  match = { class = "^(kvantummanager)$" },
  float = true,
})

hl.window_rule({
  name = "float-qt5ct",
  match = { class = "^(qt5ct)$" },
  float = true,
})

hl.window_rule({
  name = "float-dolphin-properties",
  match = { class = "^(org.kde.dolphin)$", title = "^(Properties.*)$" },
  float = true,
})

-- Janela de atalhos (SUPER+H)
hl.window_rule({
  name = "linuc-help-window",
  match = { class = "^(linuc-help)$" },
  float = true,
  center = true,
  size = "620 560",
})

-- Corrige bug conhecido de drag em janelas X11 sem classe/título (XWayland)
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Picture-in-picture
hl.window_rule({
  name = "picture-in-picture",
  match = { title = "^(Picture-in-Picture)$" },
  float = true,
  pin = true,
  size = "25% 25%",
  move = "73% 73%",
})
