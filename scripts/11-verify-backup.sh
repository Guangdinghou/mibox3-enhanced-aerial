#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/11-verify-backup.sh [--root] <备份目录>'; exit 0; }
ROOT_MODE=0
if [ "${1:-}" = --root ]; then ROOT_MODE=1; shift; fi
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
if [ "$ROOT_MODE" = 1 ]; then
  for f in boot.img recovery.img system.img install-recovery.sh; do
    [ -s "$DIR/$f" ] || die "ROOT 备份缺少或为空：$f"
    grep -Eq "^[0-9a-fA-F]{64}  ${f}$" "$DIR/manifest.sha256" || die "ROOT 备份未列入哈希清单：$f"
  done
  : > "$DIR/.root-verified"
fi
echo '备份校验通过'
