import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'theme/fluent_theme.dart';
import 'screens/windows/lock_screen_win.dart' as win;
import 'screens/windows/create_password_screen_win.dart' as win;
import 'screens/windows/main_shell_win.dart';

class InfoVaultAppWindows extends StatefulWidget {
  const InfoVaultAppWindows({super.key});
  @override
  State<InfoVaultAppWindows> createState() => _InfoVaultAppWindowsState();
}

class _InfoVaultAppWindowsState extends State<InfoVaultAppWindows> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyAcrylic());
  }

  Future<void> _applyAcrylic() async {
    try {
      // Windows 11: Mica 效果最原生；Windows 10: 用 Acrylic
      await acrylic.Window.setEffect(
        effect: acrylic.WindowEffect.mica,
        dark: WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
      );
    } catch (e) {
      // Mica 只在 Windows 11 可用，降级到 Acrylic
      debugPrint('Mica not available, falling back to Acrylic: $e');
      try {
        await acrylic.Window.setEffect(
          effect: acrylic.WindowEffect.acrylic,
          color: const Color(0xCC1E293B),
        );
      } catch (e) {
        debugPrint('Acrylic not available either: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '信息保险箱',
      debugShowCheckedModeBanner: false,
      theme: FluentAppTheme.lightTheme,
      darkTheme: FluentAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('zh', 'CN'),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.hasMasterPassword) {
            return const win.CreatePasswordScreenWin();
          }
          if (!auth.isUnlocked) {
            return const win.LockScreenWin();
          }
          return const MainShellWin();
        },
      ),
    );
  }
}
