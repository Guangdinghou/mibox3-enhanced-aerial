#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/11-verify-backup.sh <备份目录>'; exit 0; }
DIR=${1:?请指定备份目录}
for f in packages.txt disabled.txt getprop.txt settings-system.txt partition-map.txt; do
  [ -e "$DIR/$f" ] || die "缺少文件：$f"
  [ -s "$DIR/$f" ] || die "空文件：$f"
done
[ -s "$DIR/manifest.sha256" ] || die '缺少 manifest.sha256'
while read -r digest file; do
  file=${file#\*}; [ "$(sha256_file "$DIR/$file")" = "$digest" ] || die "哈希不匹配：$file"
done < "$DIR/manifest.sha256"
: > "$DIR/.verified"
echo '备份校验通过'
