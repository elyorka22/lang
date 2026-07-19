import 'package:flutter/material.dart';

/// Lingua brand palette — premium green identity.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primarySurface = Color(0xFFDCFCE7);

  static const Color secondary = Color(0xFFF5F7FA);
  static const Color accent = Color(0xFF2563EB);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color info = Color(0xFF2563EB);

  // Light — pure white + soft gray surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceElevatedDark = Color(0xFF1F2937);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF1F2937);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF9CA3AF);
  static const Color away = Color(0xFFF59E0B);

  static const Color chatBubbleMine = Color(0xFF22C55E);
  static const Color chatBubbleOther = Color(0xFFF5F7FA);
  static const Color chatBubbleOtherDark = Color(0xFF1F2937);

  static const Color xpGold = Color(0xFFF59E0B);
  static const Color streakOrange = Color(0xFFF97316);
  static const Color premiumPurple = Color(0xFF2563EB);

  /// Soft brand washes (no loud multi-stop gradients).
  static const List<Color> brandGradient = [
    Color(0xFF22C55E),
    Color(0xFF16A34A),
  ];

  static const List<Color> brandGradientSoft = [
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
  ];
}
