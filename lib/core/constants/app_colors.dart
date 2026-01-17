// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF7C6AE6);
  static const Color primaryLight = Color(0xFFA396F0);
  static const Color primaryLighter = Color(0xFFD1CAF8);
  static const Color primaryLightest = Color(0xFFF0EEFD);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Текст
  static const Color textPrimary = Color(0xFF1F1F2E);
  static const Color textSecondary = Color(0xFF6B6B82);
  static const Color textTertiary = Color(0xFFA9A9BE);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Границы
  static const Color border = Color(0xFFEAEAF2);
  static const Color borderLight = Color(0xFFF2F2F7);

  // Акцентные цвета
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Градиенты
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF7C6AE6), Color(0xFFA396F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get secondaryGradient => const LinearGradient(
    colors: [Color(0xFFF0EEFD), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
