#!/system/bin/sh
# author=HimekoEx

ROOT_UID="0"
BASE_PATH=$(cd $(dirname $0) && pwd)
API=$(getprop ro.build.version.sdk)
ABI=$(getprop ro.product.cpu.abi)

RIRU_PATH="/data/adb/riru"
RIRU_API="%%%RIRU_API%%%"
RIRU_VERSION_CODE="%%%RIRU_VERSION_CODE%%%"
RIRU_VERSION_NAME="%%%RIRU_VERSION_NAME%%%"

print() { echo "$1"; }
abort() { echo "$1" && exit 1; }

# check Root
if [ "$(id -u)" -ne "$ROOT_UID" ]; then
  print "**************************************************"
  print "! Please execute this script with root permissions!"
  abort "**************************************************"
fi
print "- Installing Riru $RIRU_VERSION_NAME ($RIRU_VERSION_CODE, API v$RIRU_API)"

# check architecture
if [ "$ABI" != "armeabi-v7a" ] && [ "$ABI" != "arm64-v8a" ]; then
  abort "! Unsupported platform: $ABI"
else
  print "- Device platform: $ABI"
fi

# check android
if [ "$API" -lt 23 ]; then
  print "*********************************************************"
  print "! Unsupported sdk: $API"
  abort "*********************************************************"
else
  print "- Device sdk: $API"
fi

# Creating Riru path
print "- Creating Riru path"
mkdir -p "$RIRU_PATH"
mkdir -p "$RIRU_PATH/bin"
chmod 770 "$RIRU_PATH"
chmod 770 "$RIRU_PATH/bin"

# Writing Riru files
print "- Writing Riru files"
echo -n "$RIRU_API" >"$RIRU_PATH/api_version.new"
chmod 660 "$RIRU_PATH/api_version.new"

libriru_32_PATH="/system/lib/libriru.so"
libriruhide_32_PATH="/system/lib/libriruhide.so"
libriruloader_32_PATH="/system/lib/libriruloader.so"
librirud_32_PATH="/system/lib/librirud.so"

libriru_64_PATH="/system/lib64/libriru.so"
libriruhide_64_PATH="/system/lib64/libriruhide.so"
libriruloader_64_PATH="/system/lib64/libriruloader.so"
librirud_64_PATH="/system/lib64/librirud.so"

# Copy 32bit lib
if [ ! -f "$libriru_32_PATH" ]; then
  print "- Copy 32bit lib"
  cp -f "$BASE_PATH/$libriru_32_PATH" "$libriru_32_PATH" && chmod 777 "$libriru_32_PATH"
  cp -f "$BASE_PATH/$libriruhide_32_PATH" "$libriruhide_32_PATH" && chmod 777 "$libriruhide_32_PATH"
  cp -f "$BASE_PATH/$libriruloader_32_PATH" "$libriruloader_32_PATH" && chmod 777 "$libriruloader_32_PATH"
  cp -f "$BASE_PATH/$librirud_32_PATH" "$RIRU_PATH/bin"

  # Copy 64bit lib
  if [ ! -f "$libriru_64_PATH" ]; then
    print "- Copy 64bit lib"
    cp -f "$BASE_PATH/$libriru_64_PATH" "$libriru_64_PATH" && chmod 777 "$libriru_64_PATH"
    cp -f "$BASE_PATH/$libriruhide_64_PATH" "$libriruhide_64_PATH" && chmod 777 "$libriruhide_64_PATH"
    cp -f "$BASE_PATH/$libriruloader_64_PATH" "$libriruloader_64_PATH" && chmod 777 "$libriruloader_64_PATH"
    cp -f "$BASE_PATH/$librirud_64_PATH" "$RIRU_PATH/bin"
  fi

  # Moving rirud
  print "- Moving rirud"
  rm -f "$RIRU_PATH/bin/rirud.new"
  mv "$RIRU_PATH/bin/librirud.so" "$RIRU_PATH/bin/rirud.new"
  chmod 777 "$RIRU_PATH/bin/rirud.new"
fi

# Copy rirud.dex
print "- Copy rirud.dex"
cp -f "$BASE_PATH/classes.dex" "$RIRU_PATH/bin"
rm -f "$RIRU_PATH/bin/rirud.dex.new"
mv "$RIRU_PATH/bin/classes.dex" "$RIRU_PATH/bin/rirud.dex.new"
chmod 777 "$RIRU_PATH/bin/rirud.dex.new"

# write api version to a persist file, only for the check process of the module installation
print "- Writing Riru files"
echo -n "$RIRU_API" >"$RIRU_PATH/api_version.new"
chmod 666 "$RIRU_PATH/api_version.new"

# Rename .new file
move_new_file() {
  if [ -f "$1.new" ]; then
    rm -f "$1"
    mv "$1.new" "$1"
  fi
}
print "- Rename .new file"
move_new_file "$RIRU_PATH/api_version"
move_new_file "$RIRU_PATH/bin/rirud"
move_new_file "$RIRU_PATH/bin/rirud.dex"

# Remove old files to avoid downgrade problems
print "- Remove old files"
rm -f /data/misc/riru/api_version
rm -f /data/misc/riru/version_code
rm -f /data/misc/riru/version_name

# Backup ro.dalvik.vm.native.bridge
print "- Backup ro.dalvik.vm.native.bridge"
echo -n "$(getprop ro.dalvik.vm.native.bridge)" >$RIRU_PATH/native_bridge

# Set rirud & Native Bridge
print "- Set rirud & Native Bridge"
INIT_FILE="/init.rc"
cat $INIT_FILE | sed 's/^    exec \/data\/adb\/riru\/bin\/rirud$//g' >$INIT_FILE
cat $INIT_FILE | sed 's/^    setprop ro\.dalvik\.vm\.native\.bridge libriruloader\.so$//g' >$INIT_FILE
cat $INIT_FILE | sed 's/^    init_user0$/    init_user0\n    exec \/data\/adb\/riru\/bin\/rirud\n    setprop ro.dalvik.vm.native.bridge libriruloader.so/g' >$INIT_FILE

# Reset ro.dalvik.vm.native.bridge or reboot if needed
#print "- Start rirud.dex"
#export CLASSPATH=/data/adb/riru/bin/rirud.dex
#app_process -Djava.class.path=/data/adb/riru/bin/rirud.dex /system/bin --nice-name=rirud_java riru.Daemon
