/// App-wide constants for Helpy Ninja
class AppConstants {
  // Private constructor
  AppConstants._();

  // App Information
  static const String appName = 'Helpy Ninja';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Supported Locales
  static const List<String> supportedLanguages = ['en', 'vi'];
  static const String defaultLanguage = 'en';

  // Animation Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 350);

  // Layout Constants
  static const double maxContentWidth = 1200.0;
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;

  // Chat Constants
  static const int maxMessageLength = 2000;
  static const int maxGroupParticipants = 8;
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);
  static const Duration messageRetryDelay = Duration(seconds: 2);

  // Local LLM Constants
  static const String phi3ModelName = 'phi3_mini.tflite';
  static const String llama32ModelName = 'llama32_1b.tflite';
  static const int maxLocalLLMTokens = 512;
  static const double complexityThreshold = 0.5;

  // Storage Keys
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
  static const String userTokenKey = 'user_token';
  static const String offlineModeKey = 'offline_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Network Constants
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(minutes: 2);
  static const int maxRetryAttempts = 3;

  // File Paths
  static const String modelsDirectory = 'assets/models/';
  static const String imagesDirectory = 'assets/images/';
  static const String animationsDirectory = 'assets/animations/';

  // Helpy Personality Types
  static const List<String> helpyPersonalities = [
    'enthusiastic',
    'patient',
    'strict',
    'friendly',
    'cool',
  ];

  // Subject Categories
  static const List<String> subjectCategories = [
    'mathematics',
    'english',
    'science',
    'history',
    'other',
  ];

  // Curriculum Types
  static const List<String> curriculumTypes = [
    'commonCore',
    'vietnamese',
    'ib',
    'custom',
  ];

  // Learning Styles
  static const List<String> learningStyles = [
    'visual',
    'auditory',
    'kinesthetic',
    'mixed',
  ];

  // Grade Levels (Vietnamese System)
  static const List<String> gradeLevelsVN = [
    'grade_1',
    'grade_2',
    'grade_3',
    'grade_4',
    'grade_5',
    'grade_6',
    'grade_7',
    'grade_8',
    'grade_9',
    'grade_10',
    'grade_11',
    'grade_12',
  ];

  // Grade Levels (US System)
  static const List<String> gradeLevelsUS = [
    'kindergarten',
    'grade_1',
    'grade_2',
    'grade_3',
    'grade_4',
    'grade_5',
    'grade_6',
    'grade_7',
    'grade_8',
    'grade_9',
    'grade_10',
    'grade_11',
    'grade_12',
  ];

  // API Endpoints (placeholder - will be configured per environment)
  static const String baseUrl = 'https://api.helpy.ninja';
  static const String apiBaseUrl = baseUrl; // Alias for API client
  static const String websocketUrl = 'wss://ws.helpy.ninja';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableVoiceInput = true;
  static const bool enableGroupChat = true;
  static const bool enableLocalLLM = true;
  static const bool enableAnalytics = false; // Disabled for privacy
  static const bool enableAuthDuringDevelopment =
      false; // Disable auth for development
      
  // Development/Offline Flags
  static const bool enableNetworkRequests = false; // Disable all network calls for development
  static const bool enableWebSocketConnection = false; // Disable WebSocket for development
  static const bool enableApiCalls = false; // Disable API calls for development
  static const bool enableLLMRequests = false; // Use mock LLM responses only
  static const bool enableImageLoading = false; // Use placeholder images only

  // UI Constants
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double chatInputMaxHeight = 120.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;

  // Performance Constants
  static const int listViewCacheExtent = 2000;
  static const int maxCachedMessages = 1000;
  static const int maxCachedConversations = 100;
}
