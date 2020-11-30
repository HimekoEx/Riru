#!/sbin/sh
# author=HimekoEx

# 变量定义
ROOT_UID="0"
BASE_PATH=$(cd $(dirname $0) && pwd)
API=$(getprop ro.build.version.sdk)
ABI=$(getprop ro.product.cpu.abi)
RIRU_PATH="/data/misc/riru"
RIRU_API="%%%RIRU_API%%%"
RIRU_VERSION_CODE="%%%RIRU_VERSION_CODE%%%"
RIRU_VERSION_NAME="%%%RIRU_VERSION_NAME%%%"

# check Root
if [ "$(id -u)" -ne "$ROOT_UID" ]; then
  echo "*********************************************************"
  echo "! 请以Root权限执行本脚本"
  echo "*********************************************************"
  exit 1
fi

# check android
if [ "$API" -lt 23 ]; then
  echo "*********************************************************"
  echo "! Unsupported sdk: $API"
  echo "*********************************************************"
  exit 1
else
  echo "- Device sdk: $API"
fi

# check architecture
if [ "$ABI" != "armeabi-v7a" ] && [ "$ABI" != "arm64-v8a" ]; then
  echo "*********************************************************"
  echo "! Unsupported platform: $ABI"
  echo "*********************************************************"
  exit 1
else
  echo "- Device platform: $ABI"
fi

# 设置权限
mkdir -p "$RIRU_PATH"
mkdir -p "$RIRU_PATH/modules"
chmod 770 "$RIRU_PATH"
chmod 770 "$RIRU_PATH/modules"

# 写出配置
echo "- Writing Riru files"
echo -n "$RIRU_API" >"$RIRU_PATH/api_version.new"
echo -n "$RIRU_VERSION_NAME" >"$RIRU_PATH/version_name.new"
echo -n "$RIRU_VERSION_CODE" >"$RIRU_PATH/version_code.new"
chmod 660 "$RIRU_PATH/api_version.new"
chmod 660 "$RIRU_PATH/version_name.new"
chmod 660 "$RIRU_PATH/version_code.new"

# generate a random name
RANDOM_NAME_FILE="/data/adb/riru/random_name"
RANDOM_NAME=""
if [ -f "$RANDOM_NAME_FILE" ]; then
  RANDOM_NAME=$(cat "$RANDOM_NAME_FILE")
else
  while true; do
    RANDOM_NAME=$(mktemp -u XXXXXXXX)
    [ -f "/system/lib/lib$RANDOM_NAME.so" ] || break
  done
  mkdir -p "/data/adb/riru"
  RANDOM_NAME=${RANDOM_NAME:0-8}
  printf "%s" "$RANDOM_NAME" >"$RANDOM_NAME_FILE"
fi
echo "- Random name is $RANDOM_NAME"

# rename .new files
move_new_file() {
  if [ -f "$1.new" ]; then
    rm -rf "$1"
    mv "$1.new" "$1"
  fi
}

move_new_file "$RIRU_PATH/api_version"
move_new_file "$RIRU_PATH/version_name"
move_new_file "$RIRU_PATH/version_code"

libmemtrack32_PATH="/system/lib/libmemtrack.so"
libmemtrack64_PATH="/system/lib64/libmemtrack.so"

# Copy libmemtrack.so
if [ ! -f "/system/lib/lib$RANDOM_NAME.so" ]; then
  echo "- Copy libmemtrack.so"
  mv "$libmemtrack32_PATH" "/system/lib/lib$RANDOM_NAME.so"
  [ -f "$libmemtrack64_PATH" ] && mv "$libmemtrack64_PATH" "/system/lib64/lib$RANDOM_NAME.so"
fi

# Copy libriru-core.so
if [ ! -f "$libmemtrack32_PATH" ]; then
  echo "- Copy libriru-core.so"
  cp -f "$BASE_PATH/$libmemtrack32_PATH" "$libmemtrack32_PATH" &&
    chmod 777 "$libmemtrack32_PATH"
  [ ! -f "$libmemtrack64_PATH" ] && cp -f "$BASE_PATH/$libmemtrack64_PATH" "$libmemtrack64_PATH" &&
    chmod 777 "$libmemtrack64_PATH"
fi
