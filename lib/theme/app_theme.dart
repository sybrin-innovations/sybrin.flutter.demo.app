import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sybrin CI Guide 2025 v3.2 – design system.
///
/// Colour authority:
///   Primary blue  #3264FA   – accent, icons, interactive elements
///   Dark          #1E1E28   – app background
///   Dark Grey     #464650   – card / surface backgrounds
///   Grey          #B2B2BC   – muted text, borders, dividers
///   White         #FFFFFF   – primary text on dark backgrounds
///   Cyan          #32C8FA   – Identity Verification feature colour (≤15%)
///   Green         #28DC78   – Digital Onboarding / success states
///   Raspberry     #F02864   – Fraud / error states
///
/// Typography: Roboto (CI mandates Roboto as the only typeface).
/// Gradients: NONE – prohibited by brand brief.
class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────────
  // Brand colour constants (CI Guide 2025 v3.2)
  // ──────────────────────────────────────────────────

  /// Sybrin Blue – primary interactive accent.
  static const Color primary = Color(0xFF3264FA);

  /// Slightly lighter tint used for pressed / hover states.
  static const Color primaryLight = Color(0xFF6690FF);

  /// Muted primary container for chip / badge backgrounds.
  static const Color primaryContainer = Color(0xFF1A2B5E);

  /// App background – Sybrin Dark.
  static const Color background = Color(0xFF1E1E28);

  /// Card / surface – Dark Grey.
  static const Color surface = Color(0xFF2C2C38);

  /// Elevated surface for nested elements (dialogs, info cards).
  static const Color surfaceVariant = Color(0xFF383848);

  /// Divider / border – Grey at reduced opacity.
  static const Color outline = Color(0xFF46464F);

  /// Primary text on dark background – White.
  static const Color onBackground = Color(0xFFFFFFFF);

  /// Secondary / muted text – CI Grey.
  static const Color onBackgroundMuted = Color(0xFFB2B2BC);

  /// Identity Verification feature colour – Cyan.
  static const Color identityCyan = Color(0xFF32C8FA);

  /// Success / confirmed state – Digital Onboarding Green.
  static const Color success = Color(0xFF28DC78);

  /// Error / risk state – Fraud Raspberry.
  static const Color error = Color(0xFFF02864);

  /// Warning – amber, kept neutral (not in CI palette, used sparingly).
  static const Color warning = Color(0xFFFAAD14);

  // ──────────────────────────────────────────────────
  // ThemeData
  // ──────────────────────────────────────────────────

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: primaryLight,
      secondary: identityCyan,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF0D3A4A),
      onSecondaryContainer: identityCyan,
      tertiary: success,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: onBackground,
      outline: outline,
      surfaceContainerHighest: surfaceVariant,
    );

    // CI mandates Roboto as the only typeface.
    final textTheme = GoogleFonts.robotoTextTheme(
      const TextTheme(
        displayLarge:  TextStyle(color: onBackground, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: onBackground, fontWeight: FontWeight.w900),
        displaySmall:  TextStyle(color: onBackground, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: onBackground, fontWeight: FontWeight.w900),
        headlineMedium:TextStyle(color: onBackground, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: onBackground, fontWeight: FontWeight.w700),
        titleLarge:    TextStyle(color: onBackground, fontWeight: FontWeight.w700),
        titleMedium:   TextStyle(color: onBackground, fontWeight: FontWeight.w500),
        titleSmall:    TextStyle(color: onBackground, fontWeight: FontWeight.w500),
        bodyLarge:     TextStyle(color: onBackground),
        bodyMedium:    TextStyle(color: onBackground),
        bodySmall:     TextStyle(color: onBackgroundMuted),
        labelLarge:    TextStyle(color: onBackground, fontWeight: FontWeight.w500),
        labelMedium:   TextStyle(color: onBackgroundMuted),
        labelSmall:    TextStyle(color: onBackgroundMuted),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,

      // Cards – flat, no elevation, hairline border
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // App bar – flush with background, no elevation
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.roboto(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Primary filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      // Outlined secondary buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      // Switches
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : onBackgroundMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withAlpha(90)
              : outline,
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(color: outline, thickness: 1),

      // Icons
      iconTheme: const IconThemeData(color: onBackground, size: 24),
    );
  }
}
