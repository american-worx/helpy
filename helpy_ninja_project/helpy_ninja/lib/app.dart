import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import 'config/config.dart';
import 'config/routes.dart';
import 'data/providers/providers.dart';

/// Main Helpy Ninja application widget
class HelpyNinjaApp extends ConsumerWidget {
  const HelpyNinjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router configuration
    final router = ref.read(goRouterProvider);

    // Watch theme state for dynamic theming
    final themeMode = ref.watch(currentThemeModeProvider);
    final lightTheme = AppTheme.lightTheme;
    final darkTheme = AppTheme.darkTheme;

    // Print environment configuration in debug mode
    AppConfig.printConfig();

    return MaterialApp.router(
      // App configuration
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.isDebug,

      // Routing
      routerConfig: router,

      // Theming - now managed by theme provider
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('vi', 'VN'), // Vietnamese
      ],
      locale: const Locale('en', 'US'), // Default locale
      // Builder for additional app-level configuration
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          // Ensure text scaling doesn't break the UI
          minScaleFactor: 0.8,
          maxScaleFactor: 1.2,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
