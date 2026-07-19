-- ~/.config/hypr/gpu.lua
-- Env vars de renderização. Esse é o fallback genérico versionado no repo.
-- O install.sh REESCREVE esse arquivo automaticamente de acordo com a GPU
-- detectada (Intel/AMD/NVIDIA) ou se estiver rodando dentro de uma VM —
-- é isso que resolve apps (kitty, a janela do SUPER+H etc) não abrirem por
-- causa de aceleração de hardware mal configurada.
hl.env("WLR_NO_HARDWARE_CURSORS", "0")
