import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dua_colors.dart';

ThemeData buildDuaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    scaffoldBackgroundColor: DuaColors.black,
    colorScheme: const ColorScheme.dark(
      primary: DuaColors.cyan,
      secondary: DuaColors.purple,
      tertiary: DuaColors.blue,
      surface: DuaColors.surface,
      error: DuaColors.offlineRed,
      onPrimary: DuaColors.black,
      onSecondary: DuaColors.textPrimary,
      onSurface: DuaColors.textPrimary,
      onError: DuaColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: DuaColors.cyanSoft),
      titleTextStyle: TextStyle(
        color: DuaColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: DuaColors.textPrimary,
      displayColor: DuaColors.textPrimary,
    ).copyWith(
      headlineLarge: const TextStyle(
        color: DuaColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: const TextStyle(
        color: DuaColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(
        color: DuaColors.textPrimary,
        fontSize: 16,
        height: 1.4,
      ),
      bodyMedium: const TextStyle(
        color: DuaColors.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: const TextStyle(
        color: DuaColors.cyanSoft,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DuaColors.surfaceElevated,
      hintStyle: const TextStyle(color: DuaColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: DuaColors.borderNeon),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: DuaColors.borderNeon),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: DuaColors.cyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: DuaColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
    cardTheme: CardThemeData(
      color: DuaColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DuaColors.borderNeon),
      ),
    ),
    dividerColor: DuaColors.borderNeon,
  );
}
