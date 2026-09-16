import 'package:flutter/material.dart';

/// Dua brand color tokens — dark neon (cyan / blue / purple).
abstract final class DuaColors {
  static const Color black = Color(0xFF050508);
  static const Color surface = Color(0xFF0C0C12);
  static const Color surfaceElevated = Color(0xFF14141E);
  static const Color card = Color(0xFF161622);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanSoft = Color(0xFF4DE8FF);
  static const Color blue = Color(0xFF3D7EFF);
  static const Color purple = Color(0xFF9B5CFF);
  static const Color magenta = Color(0xFFE040FB);

  static const Color darkNavy = Color(0xFF1A1A2E);
  static const Color darkPurple = Color(0xFF16213E);

  static const Color offlineRed = Color(0xFFE53935);
  static const Color onlineTeal = Color(0xFF00BFA5);

  static const Color textPrimary = Color(0xFFF5F7FF);
  static const Color textSecondary = Color(0xFF9AA3B8);
  static const Color textMuted = Color(0xFF6B7388);

  static const Color glowCyan = Color(0x6600E5FF);
  static const Color glowPurple = Color(0x669B5CFF);
  static const Color borderNeon = Color(0x3340C4FF);

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, blue, purple],
  );

  static const LinearGradient orbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E5FF), Color(0xFF3D7EFF), Color(0xFF9B5CFF)],
  );
}
