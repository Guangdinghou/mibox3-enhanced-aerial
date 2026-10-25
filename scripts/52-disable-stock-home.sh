#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/52-disable-stock-home.sh'; exit 0; }
require_adb; read_device_facts; require_target_device
require_confirmation '停用小米原桌面' '仅在真实遥控器已确认 Aerial 可返回 HOME 后继续。'
"$ADB" shell pm path app.orchard.tv | grep -q package: || die 'Aerial 未安装'
"$ADB" shell dumpsys package app.orchard.tv | grep -q android.intent.category.HOME || die 'Aerial 未声明 HOME'
"$ADB" shell su -c 'pm disable-user --user 0 com.mitv.tvhome'
"$ADB" shell am start -n app.orchard.tv/.MainActivity
echo '小米原桌面已可逆停用；请立即测试返回键和主页键，异常时运行 scripts/59-restore-launchers.sh。'
