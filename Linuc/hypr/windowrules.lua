-- ~/.config/hypr/windowrules.lua
-- Regras pra apps X11 (XWayland) e utilitários abrirem flutuando/corretos

hl.window_rule({ class = "^(pavucontrol)$" }, "float")
hl.window_rule({ class = "^(nm-connection-editor)$" }, "float")
hl.window_rule({ class = "^(blueman-manager)$" }, "float")
hl.window_rule({ class = "^(kvantummanager)$" }, "float")
hl.window_rule({ class = "^(qt5ct)$" }, "float")
hl.window_rule({ class = "^(org.kde.dolphin)$", title = "^(Properties.*)$" }, "float")

-- Janela de atalhos (SUPER+H)
hl.window_rule({ class = "^(linuc-help)$" }, "float", "center", "size 620 560")

-- XWayland: evita bug de janelas X11 fantasma/tamanho errado
hl.window_rule({ xwayland = true, floating = true }, "center")

-- Picture-in-picture
hl.window_rule({ title = "^(Picture-in-Picture)$" }, "float", "pin", "size 25% 25%", "move 73% 73%")
