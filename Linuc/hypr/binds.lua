-- ~/.config/hypr/binds.lua
local mod = "SUPER"

local function M(key)
  return mod .. " + " .. key
end

hl.bind(M("Return"), hl.dsp.exec_cmd("kitty"))
hl.bind(M("Q"), hl.dsp.window.close())
hl.bind(M("E"), hl.dsp.exec_cmd("dolphin"))
hl.bind(M("B"), hl.dsp.exec_cmd("firefox"))
hl.bind(M("Space"), hl.dsp.exec_cmd("walker")) -- launcher
hl.bind(M("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(M("F"), hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(M("SHIFT + Q"), hl.dsp.exit())
hl.bind(M("L"), hl.dsp.exec_cmd("hyprlock"))
hl.bind(M("P"), hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(M("J"), hl.dsp.layout("togglesplit"))
hl.bind(M("T"), hl.dsp.exec_cmd("kitty"))
hl.bind(M("H"), hl.dsp.exec_cmd("kitty --class linuc-help -e ~/.config/linuc-scripts/show-keybinds.sh"))
hl.bind(M("Print"), hl.dsp.exec_cmd("grimblast copy area"))
hl.bind(M("SHIFT + C"), hl.dsp.exec_cmd("hyprpicker -a")) -- color-picker

-- foco entre janelas
for _, dir in ipairs({
  { "l", "H" },
  { "r", "L" },
  { "u", "K" },
  { "d", "J" },
}) do
  hl.bind(M(dir[2]), hl.dsp.focus({ direction = dir[1] }))
end

-- workspaces 1-10
for i = 1, 10 do
  local key = tostring(i % 10) -- 10 vira "0"
  local ws = tostring(i)
  hl.bind(M(key), hl.dsp.focus({ workspace = ws }))
  hl.bind(M("SHIFT + " .. key), hl.dsp.window.move({ workspace = ws }))
end

-- volume / brilho
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

-- resize/move via mouse
hl.bind(M("mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(M("mouse:273"), hl.dsp.window.resize(), { mouse = true })
