// THEME LOCK: dark — source: domain signal (streaming/gaming/studio tool)
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors — StreamDash dual-platform (YouTube red + Twitch purple)
  static const Color primary = Color(0xFFE91916); // YouTube red
  static const Color primaryContainer = Color(0xFF3D0505);
  static const Color twitchPurple = Color(0xFF9146FF); // Twitch purple
  static const Color twitchPurpleContainer = Color(0xFF1E0A3C);
  static const Color secondary = Color(0xFF30D158);
  static const Color secondaryContainer = Color(0xFF0A2E16);
  static const Color warning = Color(0xFFFFD60A);
  static const Color warningContainer = Color(0xFF2E2700);
  static const Color info = Color(0xFF0A84FF);

  // Semantic colors
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF453A);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF0D0D12);
  static const Color surfaceDark = Color(0xFF14141C);
  static const Color surfaceVariantDark = Color(0xFF1E1E2A);
  static const Color glassWhite8 = Color(0x14FFFFFF);
  static const Color glassWhite12 = Color(0x1FFFFFFF);
  static const Color glassWhite5 = Color(0x0DFFFFFF);

  // Light surfaces (required)
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Gradient helpers
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFE91916), Color(0xFF9146FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFE5E3),
      onPrimaryContainer: const Color(0xFF3D0505),
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surfaceLight,
      onSurface: const Color(0xFF1A1A1A),
      error: error,
      onError: Colors.white,
      outline: const Color(0xFFCCCCCC),
      outlineVariant: const Color(0xFFEEEEEE),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.ibmPlexSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: const Color(0xFFFFCDD0),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: const Color(0xFFB8F5CA),
      surface: surfaceDark,
      onSurface: const Color(0xFFE6EDF3),
      surfaceContainerHighest: surfaceVariantDark,
      error: error,
      onError: Colors.white,
      outline: const Color(0xFF2A2A38),
      outlineVariant: const Color(0xFF1E1E2A),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.ibmPlexSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6EDF3),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6EDF3),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6EDF3),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6EDF3),
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE6EDF3),
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB8C4CE),
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8B949E),
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6EDF3),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B949E),
          letterSpacing: 0.2,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Color(0xFFE6EDF3)),
      titleTextStyle: TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE6EDF3),
      ),
    ),
    cardTheme: CardThemeData(
      color: glassWhite8,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: glassWhite8,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: twitchPurple, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
      hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x1AFFFFFF),
      thickness: 1,
      space: 1,
    ),
  );
}
