import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Palette ──
  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandBlueDark = Color(0xFF1E40AF);
  static const Color surfaceBlue = Color(0xFFEFF6FF);

  // ── Type Accent Colors ──
  static const Color passwordAccent = Color(0xFF3B82F6);
  static const Color bankAccent = Color(0xFFF59E0B);
  static const Color idAccent = Color(0xFF10B981);
  static const Color noteAccent = Color(0xFF8B5CF6);
  static const Color dangerRed = Color(0xFFDC2626);

  // ── Light Palette ──
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInputBg = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextTitle = Color(0xFF0F172A);

  // ── Dark Palette ──
  static const Color darkBg = Color(0xFF0B1120);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextTitle = Color(0xFFF8FAFC);

  // ── Radius Scale ──
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // ── Spacing Scale (4px grid) ──
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceBase = 16;
  static const double spaceLg = 20;
  static const double spaceXl = 24;
  static const double space2xl = 32;

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: brandBlue,
      onPrimary: Colors.white,
      primaryContainer: surfaceBlue,
      secondary: bankAccent,
      surface: lightCard,
      error: dangerRed,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: lightInputBg,
      outline: lightBorder,
      outlineVariant: lightBorder,
    );

    return _base(colorScheme, Brightness.light);
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E3A5F),
      secondary: bankAccent,
      surface: darkCard,
      error: Color(0xFFEF4444),
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkSurface,
      outline: darkBorder,
      outlineVariant: darkBorder,
    );

    return _base(colorScheme, Brightness.dark);
  }

  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    return (brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light)
        .copyWith(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarColor: Colors.transparent,
        );
  }

  static ThemeData _base(ColorScheme colors, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final bgColor = isLight ? lightBg : darkBg;
    final cardColor = isLight ? lightCard : darkCard;
    final mutedColor = isLight ? lightTextMuted : darkTextSecondary;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: isLight ? lightTextTitle : darkTextTitle,
        ),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
                statusBarColor: Colors.transparent,
              ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: spaceBase, vertical: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: colors.outline.withAlpha(128), width: 0.5),
        ),
      ),

      // ── Input Fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: brandBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: mutedColor, fontSize: 15),
        labelStyle: TextStyle(
          color: mutedColor, fontSize: 12, fontWeight: FontWeight.w500,
        ),
        constraints: const BoxConstraints(minHeight: 48),
      ),

      // ── Buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextSecondary,
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),

      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerHighest,
        selectedColor: colors.primaryContainer,
        shape: const StadiumBorder(),
        side: const BorderSide(color: Colors.transparent),
        labelStyle: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: isLight ? lightTextSecondary : darkTextPrimary,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: isLight ? brandBlue : const Color(0xFF3B82F6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),

      // ── Bottom Navigation ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        height: 64,
        indicatorColor: surfaceBlue,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? brandBlue : mutedColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24, color: selected ? brandBlue : mutedColor,
          );
        }),
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: colors.outline.withAlpha(128),
        thickness: 0.5,
        space: 0,
      ),

      // ── FloatingActionButton ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 0,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isLight ? Colors.grey.shade400 : Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return isLight ? Colors.grey.shade300 : Colors.grey.shade800;
        }),
      ),

      // ── Page Transition ──
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
