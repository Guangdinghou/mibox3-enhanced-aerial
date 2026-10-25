#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
[ "${1:-}" = --help ] && { echo '用法：scripts/31-install-permanent-root.sh <含完整镜像的已验证备份目录>'; exit 0; }
[ "${1:-}" = --dry-run ] && { echo '执行链：adb shell /data/local/tmp/mtk-su64 -c "sh /data/local/tmp/mibox-root/device-root-install.sh"'; exit 0; }
BAK=${1:?请指定备份目录}; require_adb; read_device_facts; require_target_device
[ -f "$BAK/.verified" ] || die '备份尚未通过校验'
for f in boot.img recovery.img system.img install-recovery.sh; do [ -s "$BAK/$f" ] || die "缺少 ROOT 前备份：$f"; done
for f in su supolicy libsupol.so SuperSU.apk install-recovery-upstream.sh; do [ -s "$ROOT/downloads/supersu/$f" ] || die "缺少人工校验的 SuperSU 2.82-SR3 资源：$f"; done
[ -s "$ROOT/downloads/mtk-su64" ] || die '缺少已校验的 mtk-su64'
require_confirmation '安装永久ROOT' '这会修改 /system。确认镜像、固件和恢复能力均已核对。'
"$ADB" install -r "$ROOT/downloads/supersu/SuperSU.apk"
"$ADB" push "$ROOT/downloads/supersu/." /data/local/tmp/mibox-root/ >/dev/null
"$ADB" push "$ROOT/assets/device-root-install.sh" /data/local/tmp/mibox-root/device-root-install.sh >/dev/null
"$ADB" push "$BAK/install-recovery.sh" /data/local/tmp/mibox-root/install-recovery-original.sh >/dev/null
"$ADB" push "$ROOT/downloads/mtk-su64" /data/local/tmp/mtk-su64 >/dev/null
"$ADB" shell chmod 700 /data/local/tmp/mtk-su64
"$ADB" shell '/data/local/tmp/mtk-su64 -c "sh /data/local/tmp/mibox-root/device-root-install.sh"'
echo '永久 ROOT 安装命令完成；必须重启并运行 scripts/90-verify.sh'
