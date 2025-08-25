import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

/// App theme configuration with modern design for tech-conscious youth
/// Features dark mode first, glassmorphism, and smooth animations
class AppTheme {
  // Private constructor
  AppTheme._();

  /// Dark theme - primary theme for tech users
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: DesignTokens.primary,
      primaryContainer: DesignTokens.primaryDark,
      secondary: DesignTokens.secondary,
      secondaryContainer: DesignTokens.secondaryDark,
      tertiary: DesignTokens.accent,
      surface: DesignTokens.backgroundDark,
      surfaceContainer: DesignTokens.surfaceDark,
      surfaceContainerHighest: DesignTokens.surfaceVariantDark,
      surfaceContainerHigh: DesignTokens.surfaceContainerDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: DesignTokens.backgroundDark,
      onSurface: DesignTokens.textPrimaryDark,
      onSurfaceVariant: DesignTokens.textSecondaryDark,
      outline: DesignTokens.textTertiaryDark,
      error: DesignTokens.error,
      onError: Colors.white,
    ),

    // Typography - Inter font for modern tech aesthetic
    textTheme: GoogleFonts.interTextTheme()
        .apply(
          bodyColor: DesignTokens.textPrimaryDark,
          displayColor: DesignTokens.textPrimaryDark,
        )
        .copyWith(
          // Display styles
          displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            height: 1.12,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.16,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.22,
          ),

          // Headline styles
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.25,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.29,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.33,
          ),

          // Title styles
          titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.27,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            height: 1.50,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            height: 1.43,
          ),

          // Body styles
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.50,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.43,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            height: 1.33,
          ),

          // Label styles
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.43,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.33,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.45,
          ),
        ),

    // App Bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.backgroundDark,
      foregroundColor: DesignTokens.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPrimaryDark,
      ),
    ),

    // Card theme with glassmorphism
    cardTheme: CardThemeData(
      color: DesignTokens.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        side: BorderSide(
          color: DesignTokens.glassBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(DesignTokens.spaceS),
    ),

    // Elevated button theme with gradients
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceL,
          vertical: DesignTokens.spaceM,
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DesignTokens.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceM,
          vertical: DesignTokens.spaceS,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.primary,
        side: const BorderSide(color: DesignTokens.primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceL,
          vertical: DesignTokens.spaceM,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        borderSide: BorderSide(color: DesignTokens.glassBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        borderSide: const BorderSide(color: DesignTokens.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        borderSide: const BorderSide(color: DesignTokens.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        borderSide: const BorderSide(color: DesignTokens.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceL,
        vertical: DesignTokens.spaceM,
      ),
      hintStyle: GoogleFonts.inter(
        color: DesignTokens.textTertiaryDark,
        fontSize: 16,
      ),
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.surfaceDark,
      selectedItemColor: DesignTokens.primary,
      unselectedItemColor: DesignTokens.textTertiaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: DesignTokens.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
      ),
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: DesignTokens.textTertiaryDark,
      thickness: 1,
      space: 1,
    ),
  );

  /// Light theme - secondary theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: DesignTokens.primary,
      primaryContainer: DesignTokens.primaryLight,
      secondary: DesignTokens.secondary,
      secondaryContainer: DesignTokens.primaryLight,
      tertiary: DesignTokens.accent,
      surface: DesignTokens.backgroundLight,
      surfaceContainer: DesignTokens.surfaceLight,
      surfaceContainerHighest: DesignTokens.surfaceVariantLight,
      surfaceContainerHigh: DesignTokens.surfaceContainerLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: DesignTokens.backgroundDark,
      onSurface: DesignTokens.textPrimaryLight,
      onSurfaceVariant: DesignTokens.textSecondaryLight,
      outline: DesignTokens.textTertiaryLight,
      error: DesignTokens.error,
      onError: Colors.white,
    ),

    // Use the same text theme but with light colors
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: DesignTokens.textPrimaryLight,
      displayColor: DesignTokens.textPrimaryLight,
    ),

    // Copy other theme configurations but adapt colors for light theme
    // (Similar structure as dark theme but with light colors)
  );
}
