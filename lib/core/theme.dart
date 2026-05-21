import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens — keep visual choices in one place.
class AppTokens {
  // Brand palette
  static const Color brandPrimary = Color(0xFF4F46E5); // indigo-600
  static const Color brandPrimaryDark = Color(0xFF6366F1); // indigo-500
  static const Color brandSuccess = Color(0xFF10B981); // emerald-500
  static const Color brandWarning = Color(0xFFF59E0B); // amber-500
  static const Color brandDanger = Color(0xFFDC2626); // red-600

  // Radii
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 22;
  static const double radius2xl = 28;

  // Spacing
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  // Typography
  static const String fontFamily = 'Segoe UI'; // Windows-native, no asset cost
  static const TextStyle numeral = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontFamilyFallback: ['Roboto', 'Helvetica'],
  );

  // Elevation
  static List<BoxShadow> softShadow(Color base, {double opacity = 0.06}) => [
        BoxShadow(
          color: base.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.brandPrimary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? AppTokens.brandPrimaryDark : AppTokens.brandPrimary,
      secondary: AppTokens.brandSuccess,
      tertiary: AppTokens.brandWarning,
      error: AppTokens.brandDanger,
      surface: isDark ? const Color(0xFF0B0D14) : const Color(0xFFFAFAFB),
      surfaceContainerLowest:
          isDark ? const Color(0xFF0F1218) : const Color(0xFFFFFFFF),
      surfaceContainerLow:
          isDark ? const Color(0xFF141821) : const Color(0xFFF5F5F7),
      surfaceContainer:
          isDark ? const Color(0xFF181C26) : const Color(0xFFF0F0F3),
      surfaceContainerHigh:
          isDark ? const Color(0xFF1E2330) : const Color(0xFFEAEAEE),
      surfaceContainerHighest:
          isDark ? const Color(0xFF252A39) : const Color(0xFFE4E4EA),
      outline: isDark ? const Color(0xFF3A3F4F) : const Color(0xFFD4D4DC),
      outlineVariant: isDark ? const Color(0xFF252A39) : const Color(0xFFE4E4EA),
    );

    final baseText = (isDark ? Typography.whiteMountainView : Typography.blackMountainView)
        .apply(fontFamily: AppTokens.fontFamily);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: AppTokens.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
        displayMedium: baseText.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineLarge: baseText.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineMedium: baseText.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        headlineSmall: baseText.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: baseText.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        labelMedium: baseText.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: AppTokens.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radius2xl)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: AppTokens.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: AppTokens.fontFamily,
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
          minimumSize: const Size(0, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(0, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primary,
        labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusXl)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        elevation: 4,
        actionTextColor: scheme.primary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
