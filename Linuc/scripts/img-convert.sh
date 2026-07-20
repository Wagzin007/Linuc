#!/usr/bin/env bash
# Converte um ou mais arquivos de imagem pro formato pedido.
# Chamado pelo menu "Converter como" do Dolphin (converter-como.desktop).
# Uso: img-convert.sh <formato> <arquivo1> [arquivo2 ...]
set -euo pipefail

format="$1"
shift

ok=0
fail=0

for file in "$@"; do
  [ -f "$file" ] || continue

  dir=$(dirname -- "$file")
  name=$(basename -- "$file")
  base="${name%.*}"
  out="$dir/$base.$format"

  # não sobrescreve sem avisar — acha o próximo nome livre
  if [ -e "$out" ]; then
    i=1
    while [ -e "$dir/${base}_$i.$format" ]; do
      i=$((i + 1))
    done
    out="$dir/${base}_$i.$format"
  fi

  if magick "$file" "$out" 2>/tmp/img-convert.err; then
    ok=$((ok + 1))
  else
    fail=$((fail + 1))
  fi
done

if command -v notify-send &>/dev/null; then
  if [ "$fail" -eq 0 ]; then
    notify-send -i image-x-generic "Conversão concluída" "$ok arquivo(s) → .$format"
  else
    notify-send -u critical "Conversão com erro" "$ok ok, $fail falharam (ver /tmp/img-convert.err)"
  fi
fi
