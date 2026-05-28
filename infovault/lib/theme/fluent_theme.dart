import 'package:fluent_ui/fluent_ui.dart';
import 'app_theme.dart';

class FluentAppTheme {
  FluentAppTheme._();

  static final lightTheme = FluentThemeData(
    brightness: Brightness.light,
    accentColor: AccentColor.swatch({
      'darkest': const Color(0xFF1A4D8F),
      'darker': const Color(0xFF1D5BA6),
      'dark': const Color(0xFF2162BD),
      'normal': AppTheme.brandBlue,
      'light': const Color(0xFF4A83F2),
      'lighter': const Color(0xFF7AA3F5),
      'lightest': const Color(0xFFB3CCFA),
    }),
    scaffoldBackgroundColor: AppTheme.lightBg,
    visualDensity: VisualDensity.standard,
    cardColor: AppTheme.lightCard,
  );

  static final darkTheme = FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({
      'darkest': const Color(0xFF1A4D8F),
      'darker': const Color(0xFF1D5BA6),
      'dark': const Color(0xFF2162BD),
      'normal': const Color(0xFF3B82F6),
      'light': const Color(0xFF4A83F2),
      'lighter': const Color(0xFF7AA3F5),
      'lightest': const Color(0xFFB3CCFA),
    }),
    scaffoldBackgroundColor: AppTheme.darkBg,
    visualDensity: VisualDensity.standard,
    cardColor: AppTheme.darkCard,
    navigationPaneTheme: const NavigationPaneThemeData(
      backgroundColor: Color(0xFF202020),
    ),
  );

  /// Type accent colors for item type indicators
  static Color typeColor(String typeName) {
    switch (typeName) {
      case 'password':
        return AppTheme.passwordAccent;
      case 'bank':
        return AppTheme.bankAccent;
      case 'id':
        return AppTheme.idAccent;
      case 'note':
        return AppTheme.noteAccent;
      case 'apiKey':
        return AppTheme.brandBlue;
      default:
        return AppTheme.brandBlue;
    }
  }

  /// Spacing helpers matching the 4px grid
  static double get spaceXs => AppTheme.spaceXs.toDouble();
  static double get spaceSm => AppTheme.spaceSm.toDouble();
  static double get spaceMd => AppTheme.spaceMd.toDouble();
  static double get spaceBase => AppTheme.spaceBase.toDouble();
  static double get spaceLg => AppTheme.spaceLg.toDouble();
  static double get spaceXl => AppTheme.spaceXl.toDouble();
  static double get space2xl => AppTheme.space2xl.toDouble();
}
