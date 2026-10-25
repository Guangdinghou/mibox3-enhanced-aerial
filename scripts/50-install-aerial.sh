#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/50-install-aerial.sh'; exit 0; }
APK="$ROOT/downloads/aerial-standard-v1.47.apk"; [ -s "$APK" ] || die '缺少已校验的 Aerial APK'
[ "$(sha256_file "$APK")" = bd32b835f3f966a348e84cadded3b1810682b25280c9dd8b4acebfb33889e0ed ] || die 'Aerial APK 哈希不匹配'
require_adb; read_device_facts; require_target_device
"$ADB" install -r "$APK"; "$ADB" shell am start -n app.orchard.tv/.MainActivity
echo 'Aerial 已安装并启动；先人工确认界面，再运行配置脚本。'
