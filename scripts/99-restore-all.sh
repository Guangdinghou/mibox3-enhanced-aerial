#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
[ "${1:-}" = --help ] && { echo '用法：scripts/99-restore-all.sh [--dry-run] <备份目录>'; exit 0; }
if [ "${1:-}" = --dry-run ]; then echo '恢复：桌面'; echo '恢复：应用'; echo '恢复：ROOT'; exit 0; fi
BAK=${1:?请指定原备份目录}
echo '恢复：桌面'; "$ROOT/scripts/59-restore-launchers.sh" "$BAK"
echo '恢复：应用'; "$ROOT/scripts/49-restore-apps.sh" "$BAK"
echo '恢复：ROOT'; "$ROOT/scripts/39-remove-permanent-root.sh"
