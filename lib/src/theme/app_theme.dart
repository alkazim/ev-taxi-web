import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CLASSIC THEME  (original green-on-greenish-white)
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  // ─── Premium "EV Green" Light Palette ───
  static const Color primaryColor = Color(0xFF10B981); // Bright Emerald
  static const Color primaryDark = Color(0xFF059669); // Deep Emerald
  static const Color primaryLight = Color(0xFF34D399); // Light Emerald

  // Greenish-white (not pure white, has green tint)
  static const Color scaffoldBackgroundColor = Color(
    0xFFEDF5F0,
  ); // Soft greenish-white
  static const Color surfaceColor = Color(
    0xFFF5FAF7,
  ); // Light greenish-white for cards
  static const Color surfaceVariant = Color(
    0xFFE8F0EB,
  ); // Slightly deeper green-white

  // Off-white for card fills (not pure #FFFFFF)
  static const Color cardFillColor = Color(
    0xFFFAFCFA,
  ); // Very subtle green-tinted white

  static const Color textColor = Color(0xFF1A2E23); // Dark forest green
  static const Color secondaryTextColor = Color(0xFF6B7B72); // Muted grey-green
  static const Color greyTextColor = Color(
    0xFF8A9490,
  ); // Grey for stats numbers

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.notoSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceVariant,
        onSurface: textColor,
        secondary: primaryLight,
        tertiary: Color(0xFF0D9488), // Classic teal accent
      ),
      cardColor: cardFillColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
      ),
      cardTheme: CardThemeData(
        color: cardFillColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
        ),
      ),
      dividerColor: const Color(0xFFD5E0D9),
      iconTheme: const IconThemeData(color: textColor),
    );
  }

  // Keep darkTheme available for future toggle
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.notoSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: Color(0xFF151B2B),
        onSurface: Colors.white,
        secondary: primaryColor,
        tertiary: Color(0xFF29B6F6),
      ),
      cardColor: const Color(0xFF151B2B),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151B2B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white24),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// V2 THEME  (white bg · vivid green primary · yellow/amber accent)
// ─────────────────────────────────────────────────────────────────────────────
class AppThemeV2 {
  // ── Palette ──
  static const Color primaryColor = Color(0xFF16A34A); // Vivid Green
  static const Color primaryDark = Color(0xFF15803D); // Deep Green
  static const Color primaryLight = Color(0xFF4ADE80); // Light Green

  static const Color accentYellow = Color(0xFFF59E0B); // Amber-500 — key accent
  static const Color accentYellowBg = Color(
    0xFFFEF3C7,
  ); // Amber-50  — badge backgrounds

  static const Color scaffoldBg = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceColor = Color(0xFFF9FAFB); // Grey-50
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Grey-100
  static const Color cardFillColor = Color(0xFFFFFFFF); // White cards

  static const Color textColor = Color(0xFF111827); // Grey-900
  static const Color secondaryTextColor = Color(0xFF6B7280); // Grey-500
  static const Color greyTextColor = Color(0xFF9CA3AF); // Grey-400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.notoSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceVariant,
        onSurface: textColor,
        secondary: primaryLight,
        tertiary: accentYellow, // ← yellow accent token used by all sections
        onTertiary: Colors.white,
      ),
      cardColor: cardFillColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
      ),
      cardTheme: CardThemeData(
        color: cardFillColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.12)),
        ),
      ),
      dividerColor: const Color(0xFFE5E7EB),
      iconTheme: const IconThemeData(color: textColor),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// YELLOW THEME  (fully yellow/amber primary — all greens become amber)
// ─────────────────────────────────────────────────────────────────────────────
class AppYellowTheme {
  // ── Palette ──
  static const Color primaryColor = Color(0xFFF59E0B); // Amber-500
  static const Color primaryDark = Color(0xFFD97706); // Amber-600
  static const Color primaryLight = Color(0xFFFBBF24); // Amber-400

  static const Color accentMark = Color(0xFFFFD700); // sentinel for detection

  static const Color scaffoldBg = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFBEB); // Amber-50
  static const Color surfaceVariant = Color(0xFFFEF3C7); // Amber-100
  static const Color cardFillColor = Color(0xFFFFFFFF);

  static const Color textColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color greyTextColor = Color(0xFF9CA3AF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.notoSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceVariant,
        onSurface: textColor,
        secondary: primaryLight,
        tertiary: accentMark, // ← sentinel so isYellowTheme returns true
        onTertiary: Colors.black87,
      ),
      cardColor: cardFillColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black87,
          textStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
      ),
      cardTheme: CardThemeData(
        color: cardFillColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.15)),
        ),
      ),
      dividerColor: const Color(0xFFE5E7EB),
      iconTheme: const IconThemeData(color: textColor),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper — detect which theme is active
// ─────────────────────────────────────────────────────────────────────────────
extension ThemeDetect on BuildContext {
  /// Returns true when the V2 (yellow-accent / green primary) theme is active.
  bool get isV2Theme =>
      Theme.of(this).colorScheme.tertiary == AppThemeV2.accentYellow;

  /// Returns true when the fully-yellow theme is active.
  bool get isYellowTheme =>
      Theme.of(this).colorScheme.tertiary == AppYellowTheme.accentMark;

  /// Returns true if either V2 or Yellow theme (modern styles) are active.
  bool get isModernStyle => isV2Theme || isYellowTheme;

  /// Shorthand accent colour — yellow in V2, gold in Yellow, teal in Classic.
  Color get accentColor => Theme.of(this).colorScheme.tertiary;

  /// Primary colour — amber in Yellow theme, green in V2/Classic.
  Color get primaryGreen => isYellowTheme
      ? AppYellowTheme.primaryColor
      : Theme.of(this).colorScheme.primary;

  /// The "call-to-action" yellow — same in both V2 and Yellow themes.
  Color get ctaYellow => const Color(0xFFF59E0B);
}
