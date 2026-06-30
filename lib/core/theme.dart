import 'package:flutter/material.dart';

/// Design tokens — keep visual choices in one place.
///
/// Implements the **Velocity POS** design system (see DESIGN.md):
/// deep navy primary, vibrant orange action accent, cool-gray canvas,
/// Hanken Grotesk typography, and a soft (small-radius) shape language.
class AppTokens {
  // ---------------------------------------------------------------------------
  // Brand palette — anchored by the logo's deep navy + vibrant orange.
  // ---------------------------------------------------------------------------
  /// Deep navy — navigation, structural headers, primary actions.
  static const Color brandPrimary = Color(0xFF002B6B);
  /// Lighter navy used as the primary tone in dark mode.
  static const Color brandPrimaryDark = Color(0xFFB0C6FF);
  /// Vibrant orange — reserved for "conversion" actions (Checkout / Pay /
  /// Finalize / New Sale). Do not use for ambient UI.
  static const Color brandSecondary = Color(0xFFFF7F27);

  // Semantic colors — high saturation for instant recognition.
  static const Color brandSuccess = Color(0xFF16A34A); // green-600
  static const Color brandWarning = Color(0xFFF59E0B); // amber-500
  static const Color brandDanger = Color(0xFFBA1A1A); // velocity error

  // ---------------------------------------------------------------------------
  // Radii — shape language is "Soft": base 0.25rem containers, 0.5rem buttons,
  // 0.75rem status chips. Overlays a little rounder.
  // ---------------------------------------------------------------------------
  static const double radiusSm = 4; // 0.25rem — base container rounding
  static const double radiusMd = 6; // 0.375rem
  static const double radiusLg = 8; // 0.5rem — buttons / actionable items
  static const double radiusXl = 12; // 0.75rem — status chips / pills
  static const double radius2xl = 16; // overlays / dialogs

  // ---------------------------------------------------------------------------
  // Spacing — 16px gutter, 24px edge margin, touch-first 48px targets.
  // ---------------------------------------------------------------------------
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16; // gutter
  static const double s5 = 20;
  static const double s6 = 24; // edge margin
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48; // touch target min

  /// Minimum interactive target — every tappable element should reach this.
  static const double touchTarget = 48;
  /// Touch-friendly input field height.
  static const double inputHeight = 56;

  // ---------------------------------------------------------------------------
  // Typography — Hanken Grotesk: sharp terminals, exceptional legibility.
  // ---------------------------------------------------------------------------
  static const String fontFamily = 'Hanken Grotesk';
  static const List<String> fontFallback = ['Segoe UI', 'Roboto', 'Helvetica'];

  /// Tabular figures — keep prices/quantities vertically aligned in lists.
  static const TextStyle numeral = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
  );

  // ---------------------------------------------------------------------------
  // Motion — quick, snappy transitions to keep the UI feeling responsive.
  // ---------------------------------------------------------------------------
  static const Duration motionFast = Duration(milliseconds: 140);
  static const Duration motionMedium = Duration(milliseconds: 240);

  // ---------------------------------------------------------------------------
  // Elevation — the system favours tonal layers over heavy shadows. These stay
  // available for the rare lift (card hover, active tile) but are deliberately
  // soft so the aesthetic remains clean and flat.
  // ---------------------------------------------------------------------------
  static List<BoxShadow> softShadow(Color base, {double opacity = 0.06}) => [
        BoxShadow(
          color: base.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Subtle Level-1 lift for resting cards / selected tiles.
  static List<BoxShadow> shadowSm() => [
        BoxShadow(
          color: const Color(0xFF181C1E).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Slightly stronger Level-2 lift for raised panels / hovered cards.
  static List<BoxShadow> shadowMd() => [
        BoxShadow(
          color: const Color(0xFF181C1E).withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// Orange "action" button style — reserved for conversion CTAs (Charge,
  /// Pay, Finalize, New Sale). Pass the current [scheme] so disabled states
  /// read correctly against the surface.
  static ButtonStyle actionButton(ColorScheme scheme) => FilledButton.styleFrom(
        backgroundColor: AppTokens.brandSecondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: scheme.surfaceContainerHigh,
        disabledForegroundColor: scheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
        minimumSize: const Size(0, AppTokens.touchTarget),
      );

  static ColorScheme _lightScheme() => const ColorScheme(
        brightness: Brightness.light,
        primary: AppTokens.brandPrimary,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF1A428A),
        onPrimaryContainer: Color(0xFF91B1FF),
        secondary: AppTokens.brandSecondary,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFFF7F27),
        onSecondaryContainer: Color(0xFF612900),
        tertiary: Color(0xFF1F2F4E),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF364566),
        onTertiaryContainer: Color(0xFFA4B3DA),
        error: AppTokens.brandDanger,
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF93000A),
        surface: Color(0xFFF7FAFC),
        onSurface: Color(0xFF181C1E),
        surfaceDim: Color(0xFFD7DADC),
        surfaceBright: Color(0xFFF7FAFC),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF1F4F6),
        surfaceContainer: Color(0xFFEBEEF0),
        surfaceContainerHigh: Color(0xFFE5E9EB),
        surfaceContainerHighest: Color(0xFFE0E3E5),
        onSurfaceVariant: Color(0xFF434651),
        outline: Color(0xFF747782),
        outlineVariant: Color(0xFFC4C6D2),
        inverseSurface: Color(0xFF2D3133),
        onInverseSurface: Color(0xFFEEF1F3),
        inversePrimary: Color(0xFFB0C6FF),
        surfaceTint: Color(0xFF395CA5),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      );

  static ColorScheme _darkScheme() => ColorScheme.fromSeed(
        seedColor: AppTokens.brandPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppTokens.brandPrimaryDark,
        onPrimary: const Color(0xFF002B6B),
        secondary: AppTokens.brandSecondary,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF763300),
        onSecondaryContainer: const Color(0xFFFFDBC9),
        error: const Color(0xFFFFB4AB),
        surface: const Color(0xFF0F1316),
        surfaceContainerLowest: const Color(0xFF14181B),
        surfaceContainerLow: const Color(0xFF1A1F22),
        surfaceContainer: const Color(0xFF1E2327),
        surfaceContainerHigh: const Color(0xFF252B30),
        surfaceContainerHighest: const Color(0xFF2F353B),
        outline: const Color(0xFF8C9199),
        outlineVariant: const Color(0xFF40464C),
      );

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark ? _darkScheme() : _lightScheme();

    final baseText = (isDark ? Typography.whiteMountainView : Typography.blackMountainView)
        .apply(fontFamily: AppTokens.fontFamily, fontFamilyFallback: AppTokens.fontFallback);

    final textTheme = baseText.copyWith(
      // display-price — readable from a distance for operator + customer.
      displayLarge: baseText.displayLarge?.copyWith(
          fontSize: 48, fontWeight: FontWeight.w700, height: 56 / 48, letterSpacing: -0.96),
      displayMedium: baseText.displayMedium?.copyWith(
          fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall: baseText.displaySmall?.copyWith(
          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      // headline-lg / headline-md
      headlineLarge: baseText.headlineLarge?.copyWith(
          fontSize: 32, fontWeight: FontWeight.w600, height: 40 / 32, letterSpacing: -0.3),
      headlineMedium: baseText.headlineMedium?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24),
      headlineSmall: baseText.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      // label-xl
      titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      titleMedium: baseText.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: baseText.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      // body-lg / body-md
      bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w400, height: 28 / 18),
      bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
      bodySmall: baseText.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14),
      // Labels carry a heavier weight so they don't wash out on colored fills.
      labelLarge: baseText.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: baseText.labelMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
      labelSmall: baseText.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: AppTokens.fontFamily,
      fontFamilyFallback: AppTokens.fontFallback,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
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
          fontFamilyFallback: AppTokens.fontFallback,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      // Level 1 — white card surfaces with a subtle 1px border (no shadow).
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
          fontFamilyFallback: AppTokens.fontFallback,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: AppTokens.fontFamily,
          fontFamilyFallback: AppTokens.fontFallback,
          fontSize: 16,
        ),
      ),
      // Primary buttons — navy fill, rounded-lg, 48px touch target.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
          minimumSize: const Size(0, AppTokens.touchTarget),
        ),
      ),
      // Ghost buttons — navy outline for secondary actions.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide(color: scheme.primary.withValues(alpha: isDark ? 0.5 : 0.35)),
          minimumSize: const Size(0, AppTokens.touchTarget),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        ),
      ),
      // Inputs — touch-friendly height; focus signalled by a 2px orange border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        constraints: const BoxConstraints(minHeight: AppTokens.inputHeight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: const BorderSide(color: AppTokens.brandSecondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
      // Status chips — rounded-xl pills.
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
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        elevation: 4,
        actionTextColor: AppTokens.brandSecondary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
