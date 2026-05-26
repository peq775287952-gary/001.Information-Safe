@echo off
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
set PUB_CACHE=H:/MyPasswords/pub_cache

echo ========================================
echo  信息保险箱 - 自动构建脚本
echo ========================================
echo.
echo [1/3] 递增版本号...
cd /d H:\MyPasswords\infovault
dart run scripts\bump_version.dart
if %errorlevel% neq 0 (
  echo 版本号更新失败!
  pause
  exit /b 1
)
echo.
echo [2/3] 安装依赖...
flutter pub get --offline
echo.
echo [3/3] 构建 Debug APK...
flutter build apk --debug --no-android-gradle-daemon
echo.
echo ========================================
echo  构建完成!
echo  APK: build\app\outputs\flutter-apk\app-debug.apk
echo ========================================
pause
