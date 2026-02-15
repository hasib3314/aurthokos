import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Deep Emerald Palette
  static const Color emeraldDarkest = Color(0xFF064E3B);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldLightest = Color(0xFF6EE7B7);

  // Soft Gold Palette
  static const Color goldDark = Color(0xFFB8860B);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF59E0B);
  static const Color goldLightest = Color(0xFFFCD34D);

  // Background Gradients
  static const Color bgDark = Color(0xFF0F1A15);
  static const Color bgMedium = Color(0xFF1A2E25);
  static const Color bgLight = Color(0xFF243B30);

  // Glass Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Category Colors
  static const Color earnColor = Color(0xFF10B981);
  static const Color expenseColor = Color(0xFFEF4444);
  static const Color loanColor = Color(0xFFF59E0B);
  static const Color savingsColor = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, bgMedium, bgDark],
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldDark, emeraldDarkest, Color(0xFF0A3D2E)],
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldDark, gold, goldLight],
  );
}
