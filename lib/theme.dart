import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///  Theme Implementation
class LightColors {
  static const background = Color(0xFFF5FAFF);
  static const foreground = Color(0xFF001E60);
  static const card = Color(0xFFF5FAFF);
  static const cardForeground = Color(0xFF001E60);
  static const popover = Color(0xFFFCFCFC);
  static const popoverForeground = Color(0xFF001E60);
  static const primary = Color(0xFF0D59CD);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF5BC5F2);
  static const secondaryForeground = Color(0xFF001E60);
  static const muted = Color(0xFF001E60);
  static const mutedForeground = Color(0xFF001E60);
  static const accent = Color(0xFF0D59CD);
  static const accentForeground = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFE54B4F);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const border = Color(0xFF001E60);
  static const input = Color(0xFFEBEBEB);
  static const ring = Color(0xFF001E60);

  // Additional colors
  static const chart1 = Color(0xFFFFAE04);
  static const chart2 = Color(0xFF0D59D1);
  static const chart3 = Color(0xFFA4A4A4);
  static const chart4 = Color(0xFFE4E4E4);
  static const chart5 = Color(0xFF747474);
}

///  dark mode colors
class DarkColors {
  static const background = Color(0xFF2C3034);
  static const foreground = Color(0xFFFFFFFF);
  static const card = Color(0xFF2C3034);
  static const cardForeground = Color(0xFFFFFFFF);
  static const popover = Color(0xFF1C2025);
  static const popoverForeground = Color(0xFFFFFFFF);
  static const primary = Color(0xFF89C5FF);
  static const primaryForeground = Color(0xFF121821);
  static const secondary = Color(0xFFFCA58B);
  static const secondaryForeground = Color(0xFF302B29);
  static const muted = Color(0xFFAED7FF);
  static const mutedForeground = Color(0xFFFFFFFF);
  static const accent = Color(0xFF333333);
  static const accentForeground = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFD93B27);
  static const destructiveForeground = Color(0xFFFDEFED);
  static const border = Color(0xFFFFFFFF);
  static const input = Color(0xFF333333);
  static const ring = Color(0xFFA4A4A4);

  // Additional colors
  static const chart1 = Color(0xFFFFAE04);
  static const chart2 = Color(0xFF0D59D1);
  static const chart3 = Color(0xFF747474);
  static const chart4 = Color(0xFF525252);
  static const chart5 = Color(0xFFE4E4E4);
  static const sidebar = Color(0xFF121212);
}

class ScoreColors extends ThemeExtension<ScoreColors> {
  final Color low; // red
  final Color mid; // amber
  final Color high; // green

  const ScoreColors({required this.low, required this.mid, required this.high});

  @override
  ThemeExtension<ScoreColors> copyWith({Color? low, Color? mid, Color? high}) =>
      ScoreColors(low: low ?? this.low, mid: mid ?? this.mid, high: high ?? this.high);

  @override
  ThemeExtension<ScoreColors> lerp(ThemeExtension<ScoreColors>? other, double t) {
    if (other is! ScoreColors) return this;
    return ScoreColors(
      low: Color.lerp(low, other.low, t) ?? low,
      mid: Color.lerp(mid, other.mid, t) ?? mid,
      high: Color.lerp(high, other.high, t) ?? high,
    );
  }
}

/// Font sizes following Material Design 3 guidelines
class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

/// Light theme with simple design
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: LightColors.primary,
    onPrimary: LightColors.primaryForeground,
    primaryContainer: LightColors.accent,
    onPrimaryContainer: LightColors.accentForeground,
    secondary: LightColors.secondary,
    onSecondary: LightColors.secondaryForeground,
    tertiary: LightColors.muted,
    onTertiary: LightColors.mutedForeground,
    error: LightColors.destructive,
    onError: LightColors.destructiveForeground,
    errorContainer: LightColors.destructive,
    onErrorContainer: LightColors.destructiveForeground,
    inversePrimary: LightColors.primaryForeground,
    shadow: Colors.black,
    surface: LightColors.background,
    onSurface: LightColors.foreground,
    surfaceContainer: LightColors.card,
    onSurfaceVariant: LightColors.mutedForeground,
    outline: LightColors.border,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightColors.background,
  cardColor: LightColors.card,
  dividerColor: LightColors.border,
  extensions: const <ThemeExtension<dynamic>>[
    ScoreColors(
      low: Color(0xFFC40000),
      mid: Color(0xFFFFC800),
      high: Color(0xFF2EB800),
    ),
  ],
  appBarTheme: const AppBarTheme(
    backgroundColor: LightColors.background,
    foregroundColor: LightColors.foreground,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: LightColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: LightColors.border, width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightColors.input,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: LightColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: LightColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: LightColors.ring, width: 2),
    ),
  ),
  iconTheme: const IconThemeData(size: 20),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: LightColors.mutedForeground,
      splashFactory: NoSplash.splashFactory,
    ),
  ),
  textTheme: _buildTextTheme(),
);

/// Dark theme with simple design
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: DarkColors.primary,
    onPrimary: DarkColors.primaryForeground,
    primaryContainer: DarkColors.accent,
    onPrimaryContainer: DarkColors.accentForeground,
    secondary: DarkColors.secondary,
    onSecondary: DarkColors.secondaryForeground,
    tertiary: DarkColors.muted,
    onTertiary: DarkColors.mutedForeground,
    error: DarkColors.destructive,
    onError: DarkColors.destructiveForeground,
    errorContainer: DarkColors.destructive,
    onErrorContainer: DarkColors.destructiveForeground,
    inversePrimary: DarkColors.primaryForeground,
    shadow: Colors.black,
    surface: DarkColors.background,
    onSurface: DarkColors.foreground,
    surfaceContainer: DarkColors.card,
    onSurfaceVariant: DarkColors.mutedForeground,
    outline: DarkColors.border,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkColors.background,
  cardColor: DarkColors.card,
  dividerColor: DarkColors.border,
  extensions: const <ThemeExtension<dynamic>>[
    ScoreColors(
      low: Color(0xFFC40000),
      mid: Color(0xFFFFC800),
      high: Color(0xFF2EB800),
    ),
  ],
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.background,
    foregroundColor: DarkColors.foreground,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: DarkColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: DarkColors.border, width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkColors.input,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DarkColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DarkColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DarkColors.ring, width: 2),
    ),
  ),
  iconTheme: const IconThemeData(size: 20),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: DarkColors.mutedForeground,
      splashFactory: NoSplash.splashFactory,
    ),
  ),
  textTheme: _buildTextTheme(),
);

/// Helper function to build consistent text theme
TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.normal,
    ),
  );
}
