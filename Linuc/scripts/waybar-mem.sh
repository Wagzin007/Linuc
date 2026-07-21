#!/usr/bin/env bash
# waybar custom/mem — texto = % de RAM usada, tooltip = detalhe (usado/livre/cache/swap)
set -euo pipefail

read -r total used free shared cache avail < <(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')
read -r swap_total swap_used < <(free -m | awk '/^Swap:/ {print $2, $3}')

pct=0
[ "$total" -gt 0 ] && pct=$(( 100 * used / total ))

class="normal"
if [ "$pct" -ge 90 ]; then
  class="critical"
elif [ "$pct" -ge 75 ]; then
  class="warning"
fi

tooltip="RAM: ${used}MiB / ${total}MiB\\n"
tooltip="${tooltip}Disponível: ${avail}MiB\\n"
tooltip="${tooltip}Cache/buffers: ${cache}MiB\\n"
tooltip="${tooltip}Swap (zram): ${swap_used}MiB / ${swap_total}MiB"

printf '{"text":"󰍛 %s%%","tooltip":"%s","class":"%s","percentage":%s}\n' "$pct" "$tooltip" "$class" "$pct"
