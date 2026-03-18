import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1F6FEB);
  static const Color primaryHover = Color(0xFF1A5ED0);
  static const Color primaryLight = Color(0xFFE8F1FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF0EA5A4);
  static const Color secondaryLight = Color(0xFFE6FFFA);

  // Neutral Colors
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Claim Priority Badges
  static const Color highPriority = Color(0xFFEF4444); // Red
  static const Color mediumPriority = Color(0xFFF59E0B); // Amber
  static const Color lowPriority = Color(0xFF10B981); // Green

  // Fraud / Risk
  static const Color fraudFlag = Color(0xFFB91C1C); // Dark Red
  static const Color suspicious = Color(0xFFF97316); // Orange

  // Dark Mode (if needed)
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkText = Color(0xFFE5E7EB);
}
