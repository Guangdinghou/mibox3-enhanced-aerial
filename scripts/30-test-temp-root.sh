#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/30-test-temp-root.sh'; exit 0; }
require_adb; read_device_facts; require_target_device
BIN="$ROOT/downloads/mtk-su64"; [ -x "$BIN" ] || die '缺少已校验且可执行的 downloads/mtk-su64'
"$ADB" push "$BIN" /data/local/tmp/mtk-su64 >/dev/null
"$ADB" shell chmod 700 /data/local/tmp/mtk-su64
OUT=$("$ADB" shell '/data/local/tmp/mtk-su64 -c id; rm -f /data/local/tmp/mtk-su64')
echo "$OUT" | grep -q 'uid=0' || die '临时 ROOT 验证失败'
"$ADB" shell getenforce | grep -q Enforcing || die 'SELinux 未恢复 Enforcing'
echo '临时 ROOT 验证通过，设备暂存文件已清理'
