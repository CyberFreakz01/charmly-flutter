import 'package:flutter/material.dart';

class CharmlyTokens {
  static const background = Color(0xFF1B1324);
  static const foreground = Color(0xFFFFF7F1);
  static const card = Color(0xFF281B34);
  static const primary = Color(0xFFFF8A75);
  static const secondary = Color(0xFF382744);
  static const muted = Color(0xFF30203D);
  static const mutedForeground = Color(0xFFBBAABD);
  static const accent = Color(0xFFBBA1FF);
  static const border = Color(0xFF453453);
  static const input = Color(0xFF594366);
  static const radius = 18.0;
}

ThemeData buildCharmlyTheme() {
  const baseText = TextStyle(
    fontFamily: 'Inter',
    color: CharmlyTokens.foreground,
  );

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CharmlyTokens.background,
    colorScheme: const ColorScheme.dark(
      surface: CharmlyTokens.card,
      primary: CharmlyTokens.primary,
      secondary: CharmlyTokens.secondary,
      onPrimary: CharmlyTokens.background,
      onSurface: CharmlyTokens.foreground,
    ),
    cardColor: CharmlyTokens.card,
    dividerColor: CharmlyTokens.border,
    textTheme: TextTheme(
      displaySmall: baseText.copyWith(fontWeight: FontWeight.w700, fontSize: 32),
      headlineSmall: baseText.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
      titleMedium: baseText.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: baseText.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
      bodyMedium: baseText.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
      labelLarge: baseText.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CharmlyTokens.input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CharmlyTokens.radius),
        borderSide: const BorderSide(color: CharmlyTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CharmlyTokens.radius),
        borderSide: const BorderSide(color: CharmlyTokens.border),
      ),
    ),
  );
}
