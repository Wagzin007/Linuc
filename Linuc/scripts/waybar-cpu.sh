#!/usr/bin/env bash
# waybar custom/cpu — texto = uso total, tooltip = uso por núcleo (via /proc/stat, sem dependências extras)
set -euo pipefail

read_stat() {
  grep '^cpu' /proc/stat
}

snap1="$(read_stat)"
sleep 0.4
snap2="$(read_stat)"

tooltip="CPU — por núcleo:\\n"
total_line_pct=""

while IFS= read -r l1 && IFS= read -r l2 <&3; do
  name=$(echo "$l1" | awk '{print $1}')
  # o "_" final descarta steal/guest/guest_nice (existem no /proc/stat de
  # qualquer kernel atual) - sem ele, esses campos caem todos concatenados
  # dentro de sirq1/sirq2 e quebram a conta la embaixo
  read -r _ u1 n1 s1 i1 io1 irq1 sirq1 _ <<< "$l1"
  read -r _ u2 n2 s2 i2 io2 irq2 sirq2 _ <<< "$l2"

  idle1=$((i1 + io1)); idle2=$((i2 + io2))
  total1=$((u1 + n1 + s1 + i1 + io1 + irq1 + sirq1))
  total2=$((u2 + n2 + s2 + i2 + io2 + irq2 + sirq2))

  dtotal=$((total2 - total1))
  didle=$((idle2 - idle1))
  pct=0
  [ "$dtotal" -gt 0 ] && pct=$(( (100 * (dtotal - didle)) / dtotal ))

  if [ "$name" = "cpu" ]; then
    total_line_pct="$pct"
  else
    core="${name#cpu}"
    tooltip="${tooltip}Núcleo ${core}: ${pct}%\\n"
  fi
done <<< "$snap1" 3<<< "$snap2"

pct="${total_line_pct:-0}"

class="normal"
if [ "$pct" -ge 90 ]; then
  class="critical"
elif [ "$pct" -ge 70 ]; then
  class="warning"
fi

printf '{"text":"󰻠 %s%%","tooltip":"%s","class":"%s","percentage":%s}\n' "$pct" "$tooltip" "$class" "$pct"
