import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Premium "EV Green" Light Palette ───
  static const Color primaryColor = Color(0xFF10B981);       // Bright Emerald
  static const Color primaryDark = Color(0xFF059669);        // Deep Emerald
  static const Color primaryLight = Color(0xFF34D399);       // Light Emerald

  // Greenish-white (not pure white, has green tint)
  static const Color scaffoldBackgroundColor = Color(0xFFEDF5F0); // Soft greenish-white
  static const Color surfaceColor = Color(0xFFF5FAF7);             // Light greenish-white for cards
  static const Color surfaceVariant = Color(0xFFE8F0EB);           // Slightly deeper green-white

  // Off-white for card fills (not pure #FFFFFF)
  static const Color cardFillColor = Color(0xFFFAFCFA);     // Very subtle green-tinted white

  static const Color textColor = Color(0xFF1A2E23);          // Dark forest green
  static const Color secondaryTextColor = Color(0xFF6B7B72); // Muted grey-green
  static const Color greyTextColor = Color(0xFF8A9490);      // Grey for stats numbers

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceVariant,
        onSurface: textColor,
        secondary: primaryLight,
        tertiary: Color(0xFF0D9488),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      cardColor: cardFillColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: Color(0xFF151B2B),
        onSurface: Colors.white,
        secondary: primaryColor,
        tertiary: Color(0xFF29B6F6),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151B2B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
