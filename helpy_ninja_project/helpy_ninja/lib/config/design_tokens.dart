import 'package:flutter/material.dart';

/// Design tokens for Helpy Ninja app
/// Inspired by modern tech apps like Discord, Figma, and Notion
/// Optimized for tech-conscious youth with dark mode first approach
class DesignTokens {
  // Private constructor to prevent instantiation
  DesignTokens._();

  // Primary Color Palette - Inspired by Discord/Figma aesthetics
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);

  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color secondaryDark = Color(0xFF7C3AED);

  static const Color accent = Color(0xFF06FFA5); // Neon Green
  static const Color accentDark = Color(0xFF10B981);

  // Dark Theme Colors (Primary)
  static const Color backgroundDark = Color(0xFF0F0F23); // Deep Navy
  static const Color surfaceDark = Color(0xFF1A1A2E); // Card backgrounds
  static const Color surfaceVariantDark = Color(0xFF16213E); // Input fields
  static const Color surfaceContainerDark = Color(
    0xFF242448,
  ); // Elevated surfaces

  // Light Theme Colors (Secondary)
  static const Color backgroundLight = Color(0xFFFAFAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color surfaceContainerLight = Color(0xFFE2E8F0);

  // Semantic Colors
  static const Color success = Color(0xFF00D9FF); // Cyan
  static const Color successDark = Color(0xFF0891B2);

  static const Color warning = Color(0xFFFFB800); // Amber
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFFF6B6B); // Coral
  static const Color errorDark = Color(0xFFDC2626);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // Gradients for modern UI
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF1A1A2E), primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass morphism colors
  static final Color glassLight = Colors.white.withValues(alpha: 0.1);
  static final Color glassDark = Colors.black.withValues(alpha: 0.2);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.2);

  // Shadows for depth
  static final List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Border radius for consistent rounded corners
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Spacing system (8px grid)
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Animation durations for micro-interactions
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
}
