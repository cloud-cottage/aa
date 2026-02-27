import 'package:flutter/material.dart';

const Color kBackground = Color(0xFF0B0B0F);
const Color kSurface = Color(0xFF14141A);
const Color kSurfaceLight = Color(0xFF1E1E24);
const Color kPrimary = Color(0xFF2C7BE5);
const Color kRed = Color(0xFF8B0000);
const Color kGold = Color(0xFFD4AF37);
const Color kGoldDark = Color(0xFF8B6914);

ThemeData gothicTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: kPrimary,
    scaffoldBackgroundColor: kBackground,
    cardColor: kSurface,
    colorScheme: ColorScheme.dark(
      primary: kPrimary,
      surface: kSurface,
      background: kBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGold,
        foregroundColor: kBackground,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: const CardThemeData(
      color: kSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white70),
    ),
  );
}
