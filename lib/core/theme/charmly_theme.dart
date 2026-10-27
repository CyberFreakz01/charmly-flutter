import 'package:flutter/material.dart';

class CharmlyColors {
  CharmlyColors._();

  static const Color text = Color(0xFFFFF7F1);
  static const Color tint = Color(0xFFFF8A75);
  static const Color background = Color(0xFF1B1324);
  static const Color foreground = Color(0xFFFFF7F1);
  static const Color card = Color(0xFF281B34);
  static const Color cardForeground = Color(0xFFFFF7F1);
  static const Color primary = Color(0xFFFF8A75);
  static const Color primaryForeground = Color(0xFF1B1324);
  static const Color secondary = Color(0xFF382744);
  static const Color secondaryForeground = Color(0xFFFFF7F1);
  static const Color muted = Color(0xFF30203D);
  static const Color mutedForeground = Color(0xFFBBAABD);
  static const Color accent = Color(0xFFBBA1FF);
  static const Color accentForeground = Color(0xFF1B1324);
  static const Color destructive = Color(0xFFFF827A);
  static const Color destructiveForeground = Color(0xFF1B1324);
  static const Color border = Color(0xFF453453);
  static const Color input = Color(0xFF594366);
}

ThemeData buildCharmlyTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: CharmlyColors.background,
    colorScheme: const ColorScheme.dark(
      primary: CharmlyColors.primary,
      onPrimary: CharmlyColors.primaryForeground,
      secondary: CharmlyColors.accent,
      onSecondary: CharmlyColors.accentForeground,
      surface: CharmlyColors.card,
      onSurface: CharmlyColors.foreground,
      error: CharmlyColors.destructive,
      onError: CharmlyColors.destructiveForeground,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: CharmlyColors.foreground,
      displayColor: CharmlyColors.foreground,
    ),
    cardTheme: const CardThemeData(
      color: CharmlyColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CharmlyColors.card,
      hintStyle: const TextStyle(color: CharmlyColors.mutedForeground),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: CharmlyColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: CharmlyColors.border),
      ),
    ),
  );
}
