import 'package:flutter/material.dart';
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

    // Typography - Using default Flutter fonts instead of Google Fonts
    textTheme:
        const TextTheme(
          // Display styles
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            height: 1.12,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.16,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.22,
          ),

          // Headline styles
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.25,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.29,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.33,
          ),

          // Title styles
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.27,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            height: 1.50,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            height: 1.43,
          ),

          // Body styles
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.50,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.43,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            height: 1.33,
          ),

          // Label styles
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.43,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.33,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.45,
          ),
        ).apply(
          bodyColor: DesignTokens.textPrimaryDark,
          displayColor: DesignTokens.textPrimaryDark,
        ),

    // App Bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.backgroundDark,
      foregroundColor: DesignTokens.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ).copyWith(color: DesignTokens.textPrimaryDark),
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
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      hintStyle: TextStyle(color: DesignTokens.textTertiaryDark, fontSize: 16),
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
    textTheme:
        const TextTheme(
          // Display styles
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            height: 1.12,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.16,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.22,
          ),

          // Headline styles
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.25,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.29,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.33,
          ),

          // Title styles
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.27,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            height: 1.50,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            height: 1.43,
          ),

          // Body styles
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.50,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.43,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            height: 1.33,
          ),

          // Label styles
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.43,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.33,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.45,
          ),
        ).apply(
          bodyColor: DesignTokens.textPrimaryLight,
          displayColor: DesignTokens.textPrimaryLight,
        ),

    // App Bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.backgroundLight,
      foregroundColor: DesignTokens.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ).copyWith(color: DesignTokens.textPrimaryLight),
    ),

    // Card theme with glassmorphism
    cardTheme: CardThemeData(
      color: DesignTokens.surfaceLight,
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
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      fillColor: DesignTokens.surfaceVariantLight,
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
      hintStyle: TextStyle(color: DesignTokens.textTertiaryLight, fontSize: 16),
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.surfaceLight,
      selectedItemColor: DesignTokens.primary,
      unselectedItemColor: DesignTokens.textTertiaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: DesignTokens.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
      ),
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: DesignTokens.textTertiaryLight,
      thickness: 1,
      space: 1,
    ),
  );
}
