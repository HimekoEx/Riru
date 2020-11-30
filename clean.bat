@echo off

del /Q /F /S "./out"
del /Q /F /S "./app/.cxx"
del /Q /F /S "./module/.cxx"
del /Q /F /S "./module/build"

rd /s /Q "./out/magisk_module"
rd /s /Q "./app/.cxx"
rd /s /Q "./module/.cxx"
rd /s /Q "./module/build"
