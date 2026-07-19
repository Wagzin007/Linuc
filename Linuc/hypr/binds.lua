-- ~/.config/hypr/binds.lua
local mod = "SUPER"

hl.bind(mod, "Return", hl.dsp.exec, "kitty")
hl.bind(mod, "Q", hl.dsp.killactive)
hl.bind(mod, "E", hl.dsp.exec, "dolphin")
hl.bind(mod, "B", hl.dsp.exec, "firefox")
hl.bind(mod, "Space", hl.dsp.exec, "walker")           -- launcher
hl.bind(mod, "V", hl.dsp.togglefloating)
hl.bind(mod, "F", hl.dsp.fullscreen, 0)
hl.bind(mod .. "SHIFT", "Q", hl.dsp.exit)
hl.bind(mod, "L", hl.dsp.exec, "hyprlock")
hl.bind(mod, "P", hl.dsp.pseudo)
hl.bind(mod, "J", hl.dsp.togglesplit)
hl.bind(mod, "T", hl.dsp.exec, "kitty -e btop")
hl.bind(mod, "H", hl.dsp.exec, "kitty --class linuc-help -e ~/.config/linuc-scripts/show-keybinds.sh")
hl.bind(mod, "Print", hl.dsp.exec, "grimblast copy area")
hl.bind(mod .. "SHIFT", "C", hl.dsp.exec, "hyprpicker -a")  -- color-picker: pega a cor do pixel e copia hex pro clipboard

-- foco entre janelas
for _, dir in ipairs({ { "left", "h" }, { "right", "l" }, { "up", "k" }, { "down", "j" } }) do
  hl.bind(mod, dir[2]:upper(), hl.dsp.movefocus, dir[1])
end

-- workspaces 1-10
for i = 1, 10 do
  local key = tostring(i % 10)
  hl.bind(mod, key, hl.dsp.workspace, tostring(i))
  hl.bind(mod .. "SHIFT", key, hl.dsp.movetoworkspace, tostring(i))
end

-- volume / brilho
hl.bind("", "XF86AudioRaiseVolume", hl.dsp.exec, "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
hl.bind("", "XF86AudioLowerVolume", hl.dsp.exec, "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
hl.bind("", "XF86AudioMute", hl.dsp.exec, "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
hl.bind("", "XF86MonBrightnessUp", hl.dsp.exec, "brightnessctl set +5%")
hl.bind("", "XF86MonBrightnessDown", hl.dsp.exec, "brightnessctl set 5%-")

-- resize/move via mouse
hl.bind_mouse(mod, "mouse:272", hl.dsp.movewindow)
hl.bind_mouse(mod, "mouse:273", hl.dsp.resizewindow)
