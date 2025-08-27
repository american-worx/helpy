import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Test helper functions for setting up test environment
class TestHelpers {
  /// Initialize Hive for testing
  static Future<void> initializeHive() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive for testing
    await Hive.initFlutter();

    // Clear any existing boxes for clean test state
    await Hive.deleteFromDisk();
  }

  /// Setup shared preferences for testing
  static void setupSharedPreferences() {
    SharedPreferences.setMockInitialValues({});
  }

  /// Setup method channel mocks for platform-specific features
  static void setupMethodChannelMocks() {
    // Mock platform channels that might be called during testing
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getAll') {
              return <String, dynamic>{}; // Return empty preferences
            }
            return null;
          },
        );

    // Mock path provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getApplicationDocumentsDirectory':
                return '/tmp/test_documents';
              case 'getTemporaryDirectory':
                return '/tmp/test_temp';
              case 'getApplicationSupportDirectory':
                return '/tmp/test_support';
              case 'getLibraryDirectory':
                return '/tmp/test_library';
              case 'getExternalStorageDirectory':
                return '/tmp/test_external';
              case 'getExternalCacheDirectories':
                return ['/tmp/test_external_cache'];
              case 'getExternalStorageDirectories':
                return ['/tmp/test_external_storage'];
              default:
                return null;
            }
          },
        );

    // Mock other platform channels as needed
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (MethodCall methodCall) async {
            return null;
          },
        );
  }

  /// Complete test environment setup
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    setupMethodChannelMocks();
    setupSharedPreferences();
    await initializeHive();
  }

  /// Clean up test environment
  static Future<void> tearDownTestEnvironment() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  }
}
