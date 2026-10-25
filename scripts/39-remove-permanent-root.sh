#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/39-remove-permanent-root.sh'; exit 0; }
require_adb; read_device_facts; require_target_device
require_confirmation '撤销永久ROOT' '将按安装清单恢复 app_process 与原厂 install-recovery。'
"$ADB" shell su -c 'test -e /system/bin/app_process64_original && mount -o remount,rw /system && rm -f /system/bin/app_process /system/bin/app_process64 /system/bin/install-recovery.sh && mv /system/bin/app_process64_original /system/bin/app_process64 && ln -s /system/bin/app_process64 /system/bin/app_process && mv /system/etc/install-recovery-2.sh /system/etc/install-recovery.sh && rm -rf /system/bin/.ext /system/xbin/su /system/xbin/daemonsu /system/xbin/supolicy /system/lib64/libsupol.so && sync && mount -o remount,ro /system'
echo 'ROOT 文件已撤销；请重启核对。'
