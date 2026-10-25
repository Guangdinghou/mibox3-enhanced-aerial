#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/49-restore-apps.sh <原备份目录>'; exit 0; }
BAK=${1:?请指定原备份目录}; require_adb; read_device_facts; require_target_device
while read -r p; do [ -z "$p" ] && continue; "$ADB" install -r "$BAK/apks/$p.apk"; done < "$BAK/removed-user0.txt"
while read -r p; do case "$p" in ''|'#'*) continue;; esac; "$ADB" shell su -c "pm enable --user 0 $p"; done < "$ROOT/config/disable.txt"
echo '应用恢复完成'
