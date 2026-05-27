import 'dart:io' show Platform;

/// 是否为桌面平台（Windows / macOS / Linux）
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// 是否为移动平台（Android / iOS）
bool get isMobile => Platform.isAndroid || Platform.isIOS;