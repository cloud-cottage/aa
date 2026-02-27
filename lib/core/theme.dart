import 'package:flutter/material.dart';

// Gothic dark theme skeleton
const Color _kBackground = Color(0xFF0B0B0F);
const Color _kSurface = Color(0xFF14141A);
const Color _kPrimary = Color(0xFF2C7BE5);
const Color _kRed = Color(0xFF8B0000);
const Color _kGold = Color(0xFFD4AF37);

ThemeData gothicTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: _kPrimary,
    scaffoldBackgroundColor: _kBackground,
    cardColor: _kSurface,
    colorScheme: ColorScheme.dark(
      primary: _kPrimary,
      surface: _kSurface,
      background: _kBackground,
    ),
    textTheme: const TextTheme(
      bodyText2: TextStyle(color: Colors.white),
    ),
  );
}
