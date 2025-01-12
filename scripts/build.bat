@echo off
echo Cleaning project...
call flutter clean

echo Installing dependencies...
call flutter pub get

echo Cleaning build_runner cache...
call dart run build_runner clean

echo Building generated files...
call dart run build_runner build --delete-conflicting-outputs

echo Done! 