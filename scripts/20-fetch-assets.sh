#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/20-fetch-assets.sh'; exit 0; }
mkdir -p "$ROOT/downloads"
while IFS='|' read -r name url digest; do
  case "$name" in ''|'#'*) continue;; esac
  tmp="$ROOT/downloads/$name.part"; out="$ROOT/downloads/$name"
  curl -fL --proto '=https' "$url" -o "$tmp"
  [ "$(sha256_file "$tmp")" = "$digest" ] || { rm -f "$tmp"; die "哈希不匹配：$name"; }
  mv "$tmp" "$out"; echo "已验证：$name"
done < "$ROOT/sources.lock"
