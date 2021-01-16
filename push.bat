@echo off

del /Q /F /S "./out"
rd /s /Q "./out/magisk_module"

call ./build.bat
adb shell rm -rf /sdcard/Riru-Shell-v23*
for %%i in (./out/*.zip) do adb push ./out/%%i /sdcard/
for %%i in (./out/*.apk) do adb push ./out/%%i /sdcard/
@REM adb push ./out/*.zip /sdcard
