import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Farver
  static const Color primaryColor = Color(0xFF007AFF); // iOS-inspireret blå
  static const Color secondaryColor = Color(0xFF34C759); // iOS-inspireret grøn
  static const Color accentColor = Color(0xFFFF9500); // iOS-inspireret orange

  // Light tema
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: Colors.white,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS-baggrund
    // SF Pro-lignende font (Inter)
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.normal),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
    ),
    // Undgå at bruge CardTheme direkte
    // Brug i stedet cardColor-egenskab
    cardColor: Colors.white,
    // iOS-inspireret knapper
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    listTileTheme: const ListTileThemeData(iconColor: primaryColor),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    // Ændrer standardanimation
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // Dark tema
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: const Color(0xFF000000), // iOS dark mode
      surface: const Color(0xFF1C1C1E), // iOS dark mode card
      onSurface: Colors.white.withOpacity(0.87),
    ),
    scaffoldBackgroundColor: const Color(0xFF000000), // iOS dark background
    // SF Pro-lignende font (Inter)
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.normal),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    // Undgå at bruge CardTheme direkte
    // Brug i stedet cardColor-egenskab
    cardColor: const Color(0xFF1C1C1E),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    listTileTheme: const ListTileThemeData(iconColor: primaryColor),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    // Ændrer standardanimation
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
