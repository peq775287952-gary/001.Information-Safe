@echo off
echo ========================================
echo 信息保险箱 Windows 版本构建
echo ========================================

cd /d %~dp0

echo [1/3] 递增版本号...
dart run scripts/bump_version.dart
if %ERRORLEVEL% NEQ 0 (
    echo 版本号递增失败！
    exit /b 1
)

echo [2/3] 构建 Windows Release...
flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo Windows 构建失败！
    exit /b 1
)

echo [3/3] 构建完成！
echo 输出目录: build\windows\x64\runner\Release\
dir build\windows\x64\runner\Release\infovault.exe