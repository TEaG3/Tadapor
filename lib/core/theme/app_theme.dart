import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان الهوية الإسلامية
  static const Color primaryGreen = Color(0xFF0B6E4F);      // أخضر إسلامي غامق
  static const Color secondaryGold = Color(0xFFC9A227);     // ذهبي
  static const Color softBeige = Color(0xFFF5F0E6);         // بيج ناعم
  static const Color deepGreen = Color(0xFF064E3B);
  static const Color lightGold = Color(0xFFE8D5A3);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFFFFFBF5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: softBeige,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryGold,
        surface: cardBg,
        onPrimary: Colors.white,
        onSecondary: textDark,
        onSurface: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.amiri(fontSize: 16, color: textDark),
        bodyMedium: GoogleFonts.amiri(fontSize: 14, color: textDark),
        labelLarge: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: secondaryGold.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: const Color(0xFF0F1A14),
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: secondaryGold,
        surface: Color(0xFF1A2A22),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.amiri(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.amiri(fontSize: 14, color: Colors.white70),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1A2A22),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: secondaryGold.withOpacity(0.4), width: 1),
        ),
      ),
    );
  }
}
