@echo off
echo Cleaning project...

echo Removing build artifacts...
rmdir /s /q build
rmdir /s /q .dart_tool
del /f /q pubspec.lock

echo Removing generated files...
del /s /q "lib\**\*.freezed.dart"
del /s /q "lib\**\*.g.dart"
del /s /q "lib\**\*.config.dart"

echo Removing test artifacts...
rmdir /s /q coverage
del /s /q "test\**\*.mocks.dart"

echo Done cleaning! 