@echo off
del /Q /F /S "./out"
del /Q /F /S "./build"
del /Q /F /S "./stub/build"
del /Q /F /S "./app/build"
del /Q /F /S "./riru/.cxx"
del /Q /F /S "./riru/build"

rd /s /Q "./out"
rd /s /Q "./build"
rd /s /Q "./stub/build"
rd /s /Q "./app/build"
rd /s /Q "./riru/.cxx"
rd /s /Q "./riru/build"
