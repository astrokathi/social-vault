import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // OLED Dark & Palette Constants matching the UI Showcase Prototype
  static const Color oled = Color(0xFF09090B);
  static const Color charcoal = Color(0xFF121216);
  static const Color elevated = Color(0xFF1C1C22);
  static const Color elevatedHover = Color(0xFF26262E);
  static const Color borderDark = Color(0xFF27272A);

  // Gradient & Brand Accents
  static const Color accentPink = Color(0xFFFF2E63);
  static const Color accentPurple = Color(0xFF7928CA);
  static const Color accentAmber = Color(0xFFF77737);
  static const Color accentCyan = Color(0xFF00D2D3);

  // Instagram Brand Gradient
  static const LinearGradient instagramGradient = LinearGradient(
    colors: [
      Color(0xFF833AB4), // Deep Purple
      Color(0xFFFD1D1D), // Vivid Red
      Color(0xFFFCB045), // Warm Gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentPillGradient = LinearGradient(
    colors: [
      Color(0xFFFF2E63),
      Color(0xFF7928CA),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: oled,
      primaryColor: accentPink,
      colorScheme: const ColorScheme.dark(
        primary: accentPink,
        secondary: accentPurple,
        tertiary: accentAmber,
        surface: oled,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: oled,
        selectedItemColor: accentPink,
        unselectedItemColor: Color(0xFF71717A),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: charcoal,
        selectedIconTheme: IconThemeData(color: accentPink),
        unselectedIconTheme: IconThemeData(color: Color(0xFF71717A)),
        selectedLabelTextStyle: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFF71717A), fontSize: 11),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFFE4E4E7),
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFFA1A1AA),
          height: 1.4,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          color: const Color(0xFF71717A),
        ),
      ),
    );
  }
}
