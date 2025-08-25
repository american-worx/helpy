import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize other services here in the future
  // - Firebase (if used)
  // - Local notifications
  // - Background services

  // Run the app with Riverpod provider scope
  runApp(const ProviderScope(child: HelpyNinjaApp()));
}
