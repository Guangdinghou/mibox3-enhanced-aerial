#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)

show_menu() {
  echo '1. 设备检查'
  echo '2. 备份'
  echo '3. 下载资源'
  echo '4. 临时 ROOT'
  echo '5. 永久 ROOT'
  echo '6. 应用清理'
  echo '7. Aerial 桌面'
  echo '8. 状态验证'
  echo '9. 完整恢复'
}

[ "${1:-}" = --list ] && { show_menu; exit 0; }

pause() { printf '\n按回车返回菜单...'; IFS= read -r _; }
ask_backup() {
  printf '请输入备份目录的完整路径：'
  IFS= read -r BACKUP_DIR
  [ -n "$BACKUP_DIR" ] || { echo '未输入路径。'; return 1; }
}

while true; do
  clear 2>/dev/null || true
  echo '小米盒子 3 增强版改造向导'
  echo '每次只执行一个阶段；红色错误出现后不要反复重试。'
  echo
  show_menu
  echo '0. 退出'
  printf '\n请选择：'
  IFS= read -r choice
  case "$choice" in
    1) "$ROOT/scripts/00-doctor.sh"; pause ;;
    2) "$ROOT/scripts/10-backup.sh"; pause ;;
    3) "$ROOT/scripts/20-fetch-assets.sh"; pause ;;
    4) "$ROOT/scripts/30-test-temp-root.sh"; pause ;;
    5) ask_backup && "$ROOT/scripts/31-install-permanent-root.sh" "$BACKUP_DIR"; pause ;;
    6) ask_backup && "$ROOT/scripts/40-debloat.sh" "$BACKUP_DIR"; pause ;;
    7)
       "$ROOT/scripts/50-install-aerial.sh"
       echo '请先在电视上确认 Aerial 可正常操作。'
       ask_backup && "$ROOT/scripts/51-configure-aerial.sh" "$BACKUP_DIR"
       echo '请用真实遥控器测试返回键和主页键；确认正常后可单独运行 scripts/52-disable-stock-home.sh。'
       pause
       ;;
    8) "$ROOT/scripts/90-verify.sh"; pause ;;
    9) ask_backup && "$ROOT/scripts/99-restore-all.sh" "$BACKUP_DIR"; pause ;;
    0) exit 0 ;;
    *) echo '无效选择。'; pause ;;
  esac
done
