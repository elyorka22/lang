import 'package:flutter/material.dart';

/// Lingua brand palette — Aurora Violet.
/// Electric violet primary with mist lilac surfaces and cyan accents.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primarySurface = Color(0xFFF3E8FF);

  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF472B6);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF38BDF8);

  // Light neutrals — soft lilac mist, not flat white
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFF5F3FF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9E3F5);
  static const Color divider = Color(0xFFF1ECF9);

  static const Color textPrimary = Color(0xFF1E1333);
  static const Color textSecondary = Color(0xFF6B6280);
  static const Color textTertiary = Color(0xFF9B93B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark neutrals — deep indigo night
  static const Color backgroundDark = Color(0xFF0C0A14);
  static const Color surfaceDark = Color(0xFF151122);
  static const Color surfaceElevatedDark = Color(0xFF1E1830);
  static const Color borderDark = Color(0xFF2E2645);
  static const Color dividerDark = Color(0xFF231C38);

  static const Color textPrimaryDark = Color(0xFFF5F3FF);
  static const Color textSecondaryDark = Color(0xFFA89BC4);
  static const Color textTertiaryDark = Color(0xFF7A6F96);

  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF9B93B0);
  static const Color away = Color(0xFFF59E0B);

  static const Color chatBubbleMine = Color(0xFF7C3AED);
  static const Color chatBubbleOther = Color(0xFFF1ECF9);
  static const Color chatBubbleOtherDark = Color(0xFF1E1830);

  static const Color xpGold = Color(0xFFFBBF24);
  static const Color streakOrange = Color(0xFFFB7185);
  static const Color premiumPurple = Color(0xFFC084FC);

  /// Hero / premium gradients
  static const List<Color> brandGradient = [
    Color(0xFF7C3AED),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
  ];

  static const List<Color> brandGradientSoft = [
    Color(0xFF7C3AED),
    Color(0xFF6366F1),
  ];
}
