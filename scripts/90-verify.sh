#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/90-verify.sh'; exit 0; }
require_adb; read_device_facts; require_target_device
echo "启动完成：$("$ADB" shell getprop sys.boot_completed | tr -d '\r')"
echo "SELinux：$("$ADB" shell getenforce | tr -d '\r')"
echo "ROOT：$("$ADB" shell su -c id 2>&1 | tr -d '\r')"
echo '已停用：'; "$ADB" shell pm list packages -d | grep -E 'com.mitv.tvhome|com.mitv.gallery|com.miui.systemAdSolution|com.miui.tv.analytics|com.xiaomi.statistic|com.xiaomi.devicereport' || true
echo '前台：'; "$ADB" shell dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' || true
echo '人工检查：真实遥控方向/返回/主页、影视仓片源、投屏、重启后 Aerial 首页。'
