#!/usr/bin/env bash
set -euo pipefail

ADB=${ADB:-adb}
TARGET_MODEL=MiBOX3_PRO
TARGET_SDK=22
TARGET_PLATFORM=mt8173

die() {
  echo "错误：$*" >&2
  exit 1
}

require_adb() {
  "$ADB" get-state >/dev/null 2>&1 || die "ADB 未连接"
}

read_device_facts() {
  DEVICE_MODEL=$("$ADB" shell getprop ro.product.model | tr -d '\r')
  DEVICE_SDK=$("$ADB" shell getprop ro.build.version.sdk | tr -d '\r')
  DEVICE_PLATFORM=$("$ADB" shell getprop ro.board.platform | tr -d '\r')
  DEVICE_CODENAME=$("$ADB" shell getprop ro.product.device | tr -d '\r')
  export DEVICE_MODEL DEVICE_SDK DEVICE_PLATFORM DEVICE_CODENAME
}

require_target_device() {
  [ "${DEVICE_MODEL:-}" = "$TARGET_MODEL" ] || die "型号不匹配：只支持 $TARGET_MODEL"
  [ "${DEVICE_SDK:-}" = "$TARGET_SDK" ] || die "SDK 不匹配：只支持 SDK $TARGET_SDK"
  case "${DEVICE_PLATFORM:-}" in
    "$TARGET_PLATFORM"*) ;;
    *) die "平台不匹配：只支持 $TARGET_PLATFORM 系列" ;;
  esac
}

require_confirmation() {
  expected=$1
  prompt=$2
  if [ "${NONINTERACTIVE:-0}" = 1 ]; then
    [ "${CONFIRM:-}" = "$expected" ] || die "非交互模式缺少确认语句：$expected"
    return
  fi
  printf '%s\n请输入：%s\n> ' "$prompt" "$expected"
  IFS= read -r answer
  [ "$answer" = "$expected" ] || die "确认语句不匹配"
}

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

run_device_step() {
  label=$1
  shift
  echo "执行：$label"
  "$@" || die "$label 失败，已停止"
}

require_safe_package_name() {
  case "$1" in
    *[!A-Za-z0-9._]*|.*|*..*|*.) die "非法包名：$1" ;;
  esac
  echo "$1" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$' || die "非法包名：$1"
}

