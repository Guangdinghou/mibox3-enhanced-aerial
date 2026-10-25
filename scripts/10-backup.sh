#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/10-backup.sh [输出目录]'; exit 0; }
require_adb; read_device_facts; require_target_device
OUT=${1:-"$ROOT/backup/$(date +%Y%m%d-%H%M%S)"}; mkdir -p "$OUT"
"$ADB" shell pm list packages -f > "$OUT/packages.txt"
"$ADB" shell pm list packages -d > "$OUT/disabled.txt"
"$ADB" shell getprop > "$OUT/getprop.txt"
"$ADB" shell settings list system > "$OUT/settings-system.txt"
"$ADB" shell settings list secure > "$OUT/settings-secure.txt"
"$ADB" shell settings list global > "$OUT/settings-global.txt"
"$ADB" shell 'cat /proc/partitions; cat /proc/mounts' > "$OUT/partition-map.txt"
for f in packages.txt disabled.txt getprop.txt settings-system.txt settings-secure.txt settings-global.txt partition-map.txt; do
  [ -s "$OUT/$f" ] || die "备份为空：$f"
done
(cd "$OUT" && for f in *.txt; do printf '%s  %s\n' "$(sha256_file "$f")" "$f"; done > manifest.sha256)
echo "基础备份完成：$OUT"
echo '永久 ROOT 前还必须按 docs/backup-and-recovery.md 备份 boot、recovery、system 与原厂启动脚本。'
