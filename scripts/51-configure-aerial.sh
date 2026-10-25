#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/51-configure-aerial.sh <备份目录>'; exit 0; }
BAK=${1:?请指定备份目录}; require_adb; read_device_facts; require_target_device
"$ADB" shell pm path app.orchard.tv | grep -q package: || die 'Aerial 未安装'
mkdir -p "$BAK"; "$ADB" shell su -c 'cat /data/data/app.orchard.tv/shared_prefs/layout.xml' > "$BAK/aerial-layout-before.xml" || true
"$ADB" push "$ROOT/config/aerial-layout.xml" /data/local/tmp/aerial-layout.xml >/dev/null
APP_UID=$("$ADB" shell dumpsys package app.orchard.tv | tr -d '\r' | sed -n 's/^[[:space:]]*userId=\([0-9][0-9]*\).*/\1/p' | sed -n '1p')
[ -n "$APP_UID" ] || die '无法读取 Aerial 的应用 UID'
"$ADB" shell am force-stop app.orchard.tv
"$ADB" shell su -c "cp /data/local/tmp/aerial-layout.xml /data/data/app.orchard.tv/shared_prefs/layout.xml; chown $APP_UID:$APP_UID /data/data/app.orchard.tv/shared_prefs/layout.xml; chmod 660 /data/data/app.orchard.tv/shared_prefs/layout.xml"
"$ADB" shell am start -n app.orchard.tv/.MainActivity
"$ADB" shell settings put secure enabled_accessibility_services app.orchard.tv/app.orchard.tv.guard.HomeGuardService
"$ADB" shell settings put secure accessibility_enabled 1
"$ADB" shell settings put secure screensaver_components app.orchard.tv/app.orchard.tv.dream.AerialDream
"$ADB" shell am broadcast -a app.orchard.tv.action.SETTINGS --ez home_in_front true -p app.orchard.tv >/dev/null
echo 'Aerial 配置完成；此后不要强制停止它，否则 Android 5.1 会移除无障碍服务。'
