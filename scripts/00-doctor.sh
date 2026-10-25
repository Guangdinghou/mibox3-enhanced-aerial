#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=../lib/guard.sh
. "$ROOT/lib/guard.sh"

if [ "${1:-}" = "--help" ]; then
  echo "用法：scripts/00-doctor.sh"
  echo "只读检查 ADB、型号、SDK 和硬件平台。"
  exit 0
fi

require_adb
read_device_facts
require_target_device

echo "设备检查通过"
echo "型号：$DEVICE_MODEL"
echo "SDK：$DEVICE_SDK"
echo "平台：$DEVICE_PLATFORM"
echo "设备代号：$DEVICE_CODENAME"
