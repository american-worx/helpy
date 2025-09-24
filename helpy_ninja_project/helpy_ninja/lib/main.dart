import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app/app_initializer.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all app services
  await AppInitializer.initialize();

  // Initialize other services here in the future
  // - Firebase (if used)
  // - Local notifications
  // - Background services

  // Run the app with Riverpod provider scope
  runApp(const ProviderScope(child: HelpyNinjaApp()));
}
