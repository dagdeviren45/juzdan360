import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.bgDark,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryGold,
        secondary: AppConstants.primaryGold,
        onPrimary: Colors.black,
        surface: AppConstants.cardDark,
        background: AppConstants.bgDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.inter(
          color: AppConstants.textLight,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        bodyLarge: GoogleFonts.inter(color: AppConstants.textLight),
        bodyMedium: GoogleFonts.inter(color: AppConstants.textGrey),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: AppConstants.textLight,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white12,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
