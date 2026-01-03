import 'package:flutter/material.dart';

/// App color palette for Burger Knight
/// Warm, appetizing colors inspired by burger aesthetics
class AppColors {
  AppColors._();

  // Primary Colors - Orange/Amber theme (appetizing, warm)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F5C);
  static const Color primaryDark = Color(0xFFE55A2B);

  // Secondary Colors - Rich brown (burger bun inspired)
  static const Color secondary = Color(0xFF8B4513);
  static const Color secondaryLight = Color(0xFFB5651D);
  static const Color secondaryDark = Color(0xFF5C2E0A);

  // Accent Colors
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFD54F);

  // Background Colors
  static const Color background = Color(0xFFFFFBF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF5F5F5);

  // Shadow Color
  static const Color shadow = Color(0x1A000000);

  // Rating Star Color
  static const Color ratingStar = Color(0xFFFFB800);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8F0), Color(0xFFFFFBF5)],
  );
}

