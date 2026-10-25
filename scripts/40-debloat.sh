#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); . "$ROOT/lib/guard.sh"
list_packages() { sed -E 's/[[:space:]]+#.*$//' "$1" | grep -vE '^[[:space:]]*(#|$)' || true; }
check_lists() {
  all=$(list_packages "$ROOT/config/disable.txt"; list_packages "$ROOT/config/remove-user0.txt")
  for p in $all; do require_safe_package_name "$p"; done
  core='^(android|com\.android\.(systemui|shell|phone|settings|packageinstaller|permissioncontroller)|com\.android\.providers\.)'
  echo "$all" | grep -Eq "$core" && die '清单包含 Android 核心包'
  overlap=$(comm -12 <(echo "$all" | sort -u) <(list_packages "$ROOT/config/keep.txt" | sort -u) || true)
  [ -z "$overlap" ] || die "清理与保留清单冲突：$overlap"
  echo '清单检查通过'
}
[ "${1:-}" = --help ] && { echo '用法：scripts/40-debloat.sh [--check-lists] <已验证备份目录>'; exit 0; }
[ "${1:-}" = --check-lists ] && { check_lists; exit 0; }
BAK=${1:?请指定已验证备份目录}; [ -f "$BAK/.verified" ] || die '备份尚未通过校验'
check_lists; require_adb; read_device_facts; require_target_device
require_confirmation '执行设备清理' '将逐包停用或从用户 0 卸载清单内应用。'
mkdir -p "$BAK/apks"; : > "$BAK/removed-user0.txt"
for p in $(list_packages "$ROOT/config/disable.txt"); do "$ADB" shell su -c "pm disable-user --user 0 $p"; done
for p in $(list_packages "$ROOT/config/remove-user0.txt"); do
  path=$("$ADB" shell pm path "$p" | tr -d '\r' | sed -n 's/^package://p')
  [ -n "$path" ] || { echo "跳过未安装：$p"; continue; }
  "$ADB" pull "$path" "$BAK/apks/$p.apk" >/dev/null
  [ -s "$BAK/apks/$p.apk" ] || die "APK 备份失败：$p"
  "$ADB" shell su -c "pm uninstall -k --user 0 $p" | grep -q Success || die "用户级卸载失败：$p"
  echo "$p" >> "$BAK/removed-user0.txt"
done
echo '清理完成；重启前先运行 scripts/90-verify.sh'
