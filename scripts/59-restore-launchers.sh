#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/59-restore-launchers.sh [含原布局的备份目录]'; exit 0; }
require_adb; read_device_facts; require_target_device
"$ADB" shell su -c 'pm enable --user 0 com.mitv.tvhome'
"$ADB" shell settings delete secure enabled_accessibility_services
"$ADB" shell settings put secure accessibility_enabled 0
"$ADB" shell settings put secure screensaver_components com.android.deskclock/com.android.deskclock.Screensaver
if [ -n "${1:-}" ] && [ -s "$1/aerial-layout-before.xml" ]; then "$ADB" push "$1/aerial-layout-before.xml" /data/local/tmp/layout.xml >/dev/null; "$ADB" shell su -c 'cp /data/local/tmp/layout.xml /data/data/app.orchard.tv/shared_prefs/layout.xml'; fi
"$ADB" shell am start -n com.mitv.tvhome/.MainActivityUserMode
echo '小米原桌面已恢复'
