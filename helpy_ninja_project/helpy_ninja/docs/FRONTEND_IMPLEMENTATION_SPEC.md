# Helpy Ninja - Frontend Implementation Specification

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Development Setup](#2-development-setup)
3. [Architecture Implementation](#3-architecture-implementation)
4. [Implementation Roadmap](#4-implementation-roadmap)
5. [Core Features Implementation](#5-core-features-implementation)
6. [Testing & Deployment](#6-testing--deployment)

## 1. Project Overview

### 1.1 Technical Stack
- **Framework**: Flutter 3.x (iOS, Android, Web)
- **State Management**: Riverpod 2.0
- **Navigation**: Go Router
- **Offline Support**: Local LLM models (Phi-3, Llama 3.2)
- **Real-time**: WebSocket for group sessions
- **Storage**: Hive for offline data, shared_preferences for settings

### 1.2 Core Features
- Personalized AI tutor (Helpy) system
- Multi-agent group learning with coordinated AI responses
- Offline-first architecture with local LLM fallback
- Real-time chat with math/code rendering
- Progressive learning dashboard with subject tracking

## 2. Development Setup

### 2.1 Project Initialization & Localization Setup
```bash
# Create Flutter project
flutter create helpy_ninja --org ninja.helpy --platforms ios,android,web
cd helpy_ninja

# Add core dependencies
flutter pub add flutter_riverpod riverpod_annotation go_router dio web_socket_channel hive hive_flutter flutter_markdown flutter_math_fork speech_to_text flutter_tts camera cached_network_image connectivity_plus tflite_flutter intl flutter_localizations

# Add Google Fonts for Vietnamese support
flutter pub add google_fonts

# Dev dependencies
flutter pub add -d riverpod_generator build_runner hive_generator json_annotation json_serializable mockito flutter_lints intl_utils

# Generate localization files
flutter pub get
flutter packages pub run intl_utils:generate
```

### 2.2 Localization Configuration
```yaml
# pubspec.yaml additions for localization
flutter:
  generate: true
  assets:
    - assets/images/
    - assets/animations/
    - assets/models/
  
# Enable internationalization
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

### 2.2 Project Structure
```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── constants.dart
│   ├── theme.dart
│   └── routes.dart
├── core/
│   ├── di/injection.dart
│   ├── network/api_client.dart
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

## 3. Architecture Implementation

### 3.1 Core Models
```dart
// domain/entities/user.dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    required UserRole role,
    UserProfile? profile,
  }) = _User;
}

// domain/entities/helpy.dart
@freezed
class Helpy with _$Helpy {
  const factory Helpy({
    required String id,
    required String name,
    required String ownerId,
    required HelpyPersonality personality,
    required String avatar,
    @Default(0) int relationshipDepth,
  }) = _Helpy;
}

// domain/entities/message.dart
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required SenderType senderType,
    required String content,
    required DateTime timestamp,
    @Default(ContentType.text) ContentType contentType,
  }) = _Message;
}
```

### 3.2 State Management Architecture (Riverpod 2.0)

**Why Riverpod over BLoC for this project:**
- **Compile-time safety**: Eliminates runtime errors with dependency injection
- **Less boilerplate**: More concise than BLoC for simple state operations
- **Better testability**: Easy to mock and override providers
- **Reactive by default**: Perfect for real-time chat and multi-agent coordination
- **Family providers**: Excellent for parameterized state (conversations, subjects)
- **Auto-dispose**: Automatic memory management for temporary state

```dart
// Core state management structure

// presentation/providers/app_providers.dart
@riverpod
class AppNotifier extends _$AppNotifier {
  @override
  AppState build() => const AppState.initial();

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
    _saveLocalePreference(locale);
  }

  void setTheme(ThemeMode theme) {
    state = state.copyWith(themeMode: theme);
    _saveThemePreference(theme);
  }

  Future<void> _saveLocalePreference(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }
}

// Family provider for conversation-specific messages
@riverpod
class ConversationMessages extends _$ConversationMessages {
  @override
  Stream<List<Message>> build(String conversationId) {
    return ref.watch(chatRepositoryProvider).messageStream(conversationId);
  }
}

// Localization providers
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Load saved locale or detect system locale
    return _getSavedLocale() ?? _detectSystemLocale();
  }

  void setLocale(Locale locale) {
    state = locale;
    _saveLocale(locale);
  }

  Locale _detectSystemLocale() {
    final systemLocale = WidgetsBinding.instance.window.locale;
    
    // Support Vietnamese and English only
    if (systemLocale.languageCode == 'vi') {
      return const Locale('vi', 'VN');
    }
    return const Locale('en', 'US'); // Default to English
  }
}

@riverpod
AppLocalizations appLocalizations(AppLocalizationsRef ref) {
  final locale = ref.watch(localeNotifierProvider);
  return lookupAppLocalizations(locale);
}
```

### 3.3 Localization Implementation

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "Helpy Ninja",
  "welcome": "Welcome",
  "meetYourHelpy": "Meet Your Helpy",
  "personalAITutor": "Your personal AI tutor that learns\nwith you, grows with you",
  "getStarted": "Get Started",
  "alreadyHaveAccount": "Already have an account?",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "askHelpyAnything": "Ask Helpy anything...",
  "helpyIsThinking": "Helpy is thinking",
  "chat": "Chat",
  "home": "Home",
  "learn": "Learn",
  "profile": "Profile",
  "subjects": "Subjects",
  "progress": "Progress",
  "settings": "Settings",
  "darkMode": "Dark Mode",
  "language": "Language",
  "offline": "Offline",
  "online": "Online",
  "loading": "Loading...",
  "error": "Error",
  "retry": "Retry"
}
```

```json
// lib/l10n/app_vi.arb
{
  "@@locale": "vi",
  "appTitle": "Helpy Ninja",
  "welcome": "Chào mừng",
  "meetYourHelpy": "Gặp gỡ Helpy của bạn",
  "personalAITutor": "Gia sư AI cá nhân học cùng bạn,\nphát triển cùng bạn",
  "getStarted": "Bắt đầu",
  "alreadyHaveAccount": "Đã có tài khoản?",
  "login": "Đăng nhập",
  "register": "Đăng ký",
  "email": "Email",
  "password": "Mật khẩu",
  "askHelpyAnything": "Hỏi Helpy bất cứ điều gì...",
  "helpyIsThinking": "Helpy đang suy nghĩ",
  "chat": "Trò chuyện",
  "home": "Trang chủ",
  "learn": "Học tập",
  "profile": "Hồ sơ",
  "subjects": "Môn học",
  "progress": "Tiến độ",
  "settings": "Cài đặt",
  "darkMode": "Chế độ tối",
  "language": "Ngôn ngữ",
  "offline": "Ngoại tuyến",
  "online": "Trực tuyến",
  "loading": "Đang tải...",
  "error": "Lỗi",
  "retry": "Thử lại"
}
```

### 3.4 Multi-Agent Group Chat
```dart
// data/services/group_chat_service.dart
class GroupChatService {
  final WebSocketService _websocket;
  final MultiAgentCoordinator _coordinator;

  Future<void> joinGroupSession(String sessionId, String helpyId) async {
    await _websocket.send({
      'type': 'join_group',
      'sessionId': sessionId,
      'helpyId': helpyId,
    });
  }

  Stream<GroupMessage> get groupMessageStream => 
    _websocket.messageStream
      .where((msg) => msg['type'] == 'group_message')
      .map((msg) => GroupMessage.fromJson(msg));

  Future<void> sendGroupMessage(String content, GroupSession session) async {
    // Coordinate response with other Helpys
    final canRespond = await _coordinator.checkResponsePermission(
      session.id, 
      session.myHelpy.id,
    );
    
    if (canRespond) {
      await _websocket.send({
        'type': 'group_message',
        'sessionId': session.id,
        'helpyId': session.myHelpy.id,
        'content': content,
      });
    }
  }
}
```

## 4. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
**Week 1**: Project setup, navigation, basic UI
- Initialize Flutter project with clean architecture
- Setup Go Router with authentication guards
- Implement theme system and basic components
- Create user models and authentication flow

**Week 2**: Authentication and onboarding
- Complete login/register screens
- Implement profile setup with Helpy customization
- Add subject selection and learning goals
- Setup local storage with Hive

### Phase 2: Basic Chat (Weeks 3-4)
**Week 3**: Chat UI implementation
- Create chat screen with message bubbles
- Implement markdown rendering for math/code
- Add typing indicators and message status
- Setup message input with voice capabilities

**Week 4**: Chat functionality
- Integrate with mock LLM API
- Implement real-time messaging
- Add conversation management
- Create offline message queuing

### Phase 3: Multi-Agent System (Weeks 5-6)
**Week 5**: Group infrastructure
- Design group session management
- Implement WebSocket service for real-time updates
- Create participant tracking system
- Setup multi-Helpy coordination logic

**Week 6**: Group chat coordination
- Implement response coordination between multiple AIs
- Add turn-taking system to prevent chaos
- Create group dynamics balancing
- Build group chat UI with multiple Helpy indicators

### Phase 4: Offline & Learning (Weeks 7-8)
**Week 7**: Offline capabilities
- Integrate TensorFlow Lite for local models
- Implement intelligent model routing (local vs cloud)
- Create offline sync mechanism
- Add bandwidth-aware feature toggling

**Week 8**: Learning features
- Implement subject progress tracking
- Add interactive whiteboard
- Create assessment and practice modes
- Build progress visualization dashboard

## 5. Modern UI/UX Design System

### 5.1 Design Philosophy
**Target Audience**: Tech-conscious youth (13-25 years old)
**Core Principles**:
- **Minimalist Brutalism**: Clean, bold, functional
- **Dark Mode First**: Primary dark theme with light mode option
- **Micro-interactions**: Subtle animations that provide feedback
- **Information Hierarchy**: Clear visual structure without clutter
- **Performance Perception**: Fast, responsive feel even during processing

### 5.2 Color System & Theming
```dart
// config/design_tokens.dart
class DesignTokens {
  // Primary Color Palette - Inspired by Discord/Figma aesthetics
  static const Color primary = Color(0xFF6366F1);      // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF8B5CF6);    // Purple
  static const Color accent = Color(0xFF06FFA5);       // Neon Green
  
  // Dark Theme (Primary)
  static const Color backgroundDark = Color(0xFF0F0F23);      // Deep Navy
  static const Color surfaceDark = Color(0xFF1A1A2E);        // Card backgrounds
  static const Color surfaceVariantDark = Color(0xFF16213E);  // Input fields
  
  // Light Theme (Secondary)
  static const Color backgroundLight = Color(0xFFFAFAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  // Semantic Colors
  static const Color success = Color(0xFF00D9FF);      // Cyan
  static const Color warning = Color(0xFFFFB800);      // Amber
  static const Color error = Color(0xFFFF6B6B);        // Coral
  
  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);
}

// Advanced theme with custom components
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: DesignTokens.primary,
      secondary: DesignTokens.secondary,
      background: DesignTokens.backgroundDark,
      surface: DesignTokens.surfaceDark,
      surfaceVariant: DesignTokens.surfaceVariantDark,
    ),
    // Custom typography inspired by SF Pro / Inter
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: DesignTokens.textPrimaryDark,
      displayColor: DesignTokens.textPrimaryDark,
    ).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    ),
    // Custom component themes
    extensions: {
      CustomButtonTheme(
        primaryStyle: _buildGlassyButtonStyle(),
        secondaryStyle: _buildOutlineButtonStyle(),
      ),
      ChatBubbleTheme(
        userBubbleColor: DesignTokens.primary,
        helpyBubbleColor: DesignTokens.surfaceVariantDark,
        borderRadius: 20,
      ),
    },
  );
}
```

### 5.3 Modern Component Design

#### Glassmorphism Chat Interface
```dart
// presentation/widgets/chat/modern_message_bubble.dart
class ModernMessageBubble extends StatelessWidget {
  const ModernMessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    this.showHelpyInfo = false,
  });

  final Message message;
  final bool isOwn;
  final bool showHelpyInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isOwn ? 60 : 16,
        right: isOwn ? 16 : 60,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showHelpyInfo && !isOwn) ..._buildHelpyHeader(),
          _buildMessageContainer(context),
          _buildTimestamp(context),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isOwn
            ? LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isOwn ? null : DesignTokens.surfaceVariantDark,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isOwn ? const Radius.circular(6) : null,
          bottomLeft: !isOwn ? const Radius.circular(6) : null,
        ),
        border: !isOwn
            ? Border.all(
                color: DesignTokens.textTertiaryDark.withOpacity(0.1),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(context),
          if (message.contentType == ContentType.code) ..._buildCodeActions(),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return MarkdownBody(
      data: message.content,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: isOwn ? Colors.white : DesignTokens.textPrimaryDark,
          fontSize: 15,
          height: 1.4,
        ),
        code: TextStyle(
          backgroundColor: Colors.black.withOpacity(0.2),
          fontFamily: 'JetBrains Mono',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onTapLink: (text, href, title) => _handleLinkTap(href),
    );
  }

  List<Widget> _buildHelpyHeader() {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 48, bottom: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: DesignTokens.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.accent.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.senderName ?? 'Helpy',
              style: TextStyle(
                color: DesignTokens.textSecondaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
```

#### Modern Input Interface
```dart
// presentation/widgets/chat/modern_chat_input.dart
class ModernChatInput extends StatefulWidget {
  const ModernChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
  });

  final Function(String) onSendMessage;
  final bool isLoading;

  @override
  State<ModernChatInput> createState() => _ModernChatInputState();
}

class _ModernChatInputState extends State<ModernChatInput>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _sendButtonController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceDark,
        border: Border(
          top: BorderSide(
            color: DesignTokens.textTertiaryDark.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildActionButton(
              icon: Icons.add_circle_outline,
              onTap: _showAttachmentOptions,
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildTextInput()),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceVariantDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _focusNode.hasFocus
              ? DesignTokens.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: 4,
        minLines: 1,
        style: const TextStyle(
          color: DesignTokens.textPrimaryDark,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Ask Helpy anything...',
          hintStyle: TextStyle(
            color: DesignTokens.textTertiaryDark,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        onSubmitted: _hasText ? _sendMessage : null,
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _sendButtonController,
      child: _buildActionButton(
        icon: widget.isLoading ? null : Icons.send_rounded,
        gradient: LinearGradient(
          colors: [DesignTokens.primary, DesignTokens.secondary],
        ),
        onTap: _hasText ? _sendMessage : null,
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : null,
      ),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_sendButtonController.value * 0.2),
          child: child,
        );
      },
    );
  }
}
```

### 5.4 Navigation & Layout

#### Modern Bottom Navigation
```dart
// presentation/widgets/navigation/modern_bottom_nav.dart
class ModernBottomNav extends StatelessWidget {
  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: DesignTokens.surfaceDark.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: DesignTokens.textTertiaryDark.withOpacity(0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildNavItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.chat_bubble_rounded, 'Chat'),
      (Icons.school_rounded, 'Learn'),
      (Icons.person_rounded, 'Profile'),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final (icon, label) = entry.value;
      final isSelected = index == currentIndex;

      return GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? DesignTokens.primary
                    : DesignTokens.textTertiaryDark,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? DesignTokens.primary
                      : DesignTokens.textTertiaryDark,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
```

### 5.5 Micro-interactions & Animations

#### Helpy Thinking Animation
```dart
// presentation/widgets/chat/helpy_thinking_indicator.dart
class HelpyThinkingIndicator extends StatefulWidget {
  const HelpyThinkingIndicator({super.key});

  @override
  State<HelpyThinkingIndicator> createState() => _HelpyThinkingIndicatorState();
}

class _HelpyThinkingIndicatorState extends State<HelpyThinkingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Timer(Duration(milliseconds: i * 200), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(right: 60, left: 16, bottom: 8),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceVariantDark,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomLeft: const Radius.circular(6),
        ),
        border: Border.all(
          color: DesignTokens.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Helpy is thinking',
            style: TextStyle(
              color: DesignTokens.textSecondaryDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: _animations.asMap().entries.map((entry) {
              return AnimatedBuilder(
                animation: entry.value,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.only(left: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: DesignTokens.accent.withOpacity(
                        0.3 + (entry.value.value * 0.7),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
```

### 5.6 Modern Onboarding Experience

#### Animated Welcome Screen
```dart
// presentation/screens/onboarding/modern_welcome_screen.dart
class ModernWelcomeScreen extends StatefulWidget {
  const ModernWelcomeScreen({super.key});

  @override
  State<ModernWelcomeScreen> createState() => _ModernWelcomeScreenState();
}

class _ModernWelcomeScreenState extends State<ModernWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Timer(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignTokens.backgroundDark,
              Color(0xFF1A1A2E),
              DesignTokens.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  child: _buildHeroSection(),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    );
                  },
                ),
                const Spacer(),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildActionButtons(context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Animated logo with glow effect
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        
        // Title with gradient text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, DesignTokens.accent],
          ).createShader(bounds),
          child: Text(
            'Meet Your Helpy',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Subtitle
        Text(
          'Your personal AI tutor that learns\nwith you, grows with you',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            color: DesignTokens.textSecondaryDark,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary CTA button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.secondary],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go('/onboarding/profile'),
              child: Center(
                child: Text(
                  'Get Started',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Secondary button
        TextButton(
          onPressed: () => context.go('/auth/login'),
          child: Text(
            'Already have an account?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: DesignTokens.textSecondaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
```

### 5.7 Modern Dashboard Design

#### Glassmorphism Dashboard Cards
```dart
// presentation/widgets/dashboard/modern_dashboard_card.dart
class ModernDashboardCard extends StatelessWidget {
  const ModernDashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.gradient,
    this.onTap,
  });

  final String title;
  final Widget child;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? DesignTokens.surfaceVariantDark : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: gradient != null 
                          ? Colors.white 
                          : DesignTokens.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern progress indicators
class ModernProgressRing extends StatelessWidget {
  const ModernProgressRing({
    super.key,
    required this.progress,
    required this.size,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation(
              backgroundColor ?? Colors.white.withOpacity(0.2),
            ),
          ),
          // Progress circle
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation(
              progressColor ?? DesignTokens.accent,
            ),
          ),
          // Center text
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: size * 0.15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.8 Advanced UI Patterns

#### Pull-to-Refresh with Custom Animation
```dart
// presentation/widgets/common/modern_refresh_indicator.dart
class ModernRefreshIndicator extends StatelessWidget {
  const ModernRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: DesignTokens.surfaceDark,
      color: DesignTokens.accent,
      strokeWidth: 3,
      displacement: 60,
      child: child,
    );
  }
}
```

#### Modern Loading States
```dart
// presentation/widgets/common/modern_loading_widget.dart
class ModernLoadingWidget extends StatefulWidget {
  const ModernLoadingWidget({
    super.key,
    this.size = 48,
    this.message,
  });

  final double size;
  final String? message;

  @override
  State<ModernLoadingWidget> createState() => _ModernLoadingWidgetState();
}

class _ModernLoadingWidgetState extends State<ModernLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseController]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      DesignTokens.primary,
                      DesignTokens.secondary,
                      DesignTokens.accent,
                      DesignTokens.primary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.primary.withOpacity(
                        0.3 + (_pulseController.value * 0.4),
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: DesignTokens.backgroundDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ..[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: GoogleFonts.inter(
              color: DesignTokens.textSecondaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
```

### 5.9 Gesture-Based Interactions

#### Swipe Actions for Messages
```dart
// presentation/widgets/chat/swipe_message_bubble.dart
class SwipeMessageBubble extends StatefulWidget {
  const SwipeMessageBubble({
    super.key,
    required this.message,
    required this.child,
    this.onReply,
    this.onReact,
  });

  final Message message;
  final Widget child;
  final VoidCallback? onReply;
  final VoidCallback? onReact;

  @override
  State<SwipeMessageBubble> createState() => _SwipeMessageBubbleState();
}

class _SwipeMessageBubbleState extends State<SwipeMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -5 && !_isRevealed) {
          setState(() => _isRevealed = true);
          _slideController.forward();
        } else if (details.delta.dx > 5 && _isRevealed) {
          setState(() => _isRevealed = false);
          _slideController.reverse();
        }
      },
      child: Stack(
        children: [
          // Action buttons (revealed on swipe)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.reply_rounded,
                  color: DesignTokens.primary,
                  onTap: widget.onReply,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.favorite_rounded,
                  color: DesignTokens.error,
                  onTap: widget.onReact,
                ),
              ],
            ),
          ),
          // Message bubble
          SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        setState(() => _isRevealed = false);
        _slideController.reverse();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
```

### 5.10 Dark Mode Excellence

#### Dynamic Theme Switching
```dart
// presentation/providers/theme_provider.dart
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    return ThemeMode.dark; // Default to dark mode
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemePreference();
  }

  void setSystemTheme() {
    state = ThemeMode.system;
    _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', state.name);
  }
}

// Advanced theme with better contrast ratios
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: DesignTokens.primary,
      secondary: DesignTokens.secondary,
      background: DesignTokens.backgroundDark,
      surface: DesignTokens.surfaceDark,
      surfaceVariant: DesignTokens.surfaceVariantDark,
      onPrimary: Colors.white,
      onBackground: DesignTokens.textPrimaryDark,
      onSurface: DesignTokens.textPrimaryDark,
    ),
    // Ensure high contrast for accessibility
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: DesignTokens.textPrimaryDark,
      displayColor: DesignTokens.textPrimaryDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}
```

## 6. Core Features Implementation

### 6.1 Chat Interface
```dart
// presentation/widgets/chat/message_bubble.dart
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    this.showHelpyInfo = false,
  });

  final Message message;
  final bool isOwn;
  final bool showHelpyInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showHelpyInfo && !isOwn) ...[
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                message.senderName ?? 'Helpy',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          Row(
            mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isOwn) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(message.senderAvatar ?? ''),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOwn ? Theme.of(context).primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isOwn ? const Radius.circular(4) : null,
                      bottomLeft: !isOwn ? const Radius.circular(4) : null,
                    ),
                  ),
                  child: MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: isOwn ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 5.2 Local LLM Integration
```dart
// data/services/local_llm_service.dart
class LocalLLMService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel(String modelPath) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isModelLoaded = true;
    } catch (e) {
      throw LLMException('Failed to load local model: $e');
    }
  }

  Future<String> generateResponse(String prompt, {String? context}) async {
    if (!_isModelLoaded) {
      throw LLMException('Local model not loaded');
    }

    // Simple tokenization (implement proper tokenizer)
    final inputText = context != null ? '$context\n$prompt' : prompt;
    final tokens = _tokenize(inputText);
    
    // Run inference
    final output = List.filled(256, 0).reshape([1, 256]);
    _interpreter!.run([tokens], {'output': output});
    
    return _detokenize(output[0]);
  }

  Future<bool> isModelAvailable() async {
    return _isModelLoaded;
  }
}

// Smart routing between local and cloud LLM
class LLMRouter {
  final LocalLLMService _localLLM;
  final CloudLLMService _cloudLLM;
  final ConnectivityService _connectivity;

  Future<String> generateResponse(String prompt, {String? context}) async {
    final isOnline = await _connectivity.isConnected();
    final complexity = _assessComplexity(prompt);
    
    // Use local LLM for simple queries or when offline
    if (!isOnline || complexity < 0.5) {
      try {
        return await _localLLM.generateResponse(prompt, context: context);
      } catch (e) {
        if (isOnline) {
          return await _cloudLLM.generateResponse(prompt, context: context);
        }
        rethrow;
      }
    }
    
    // Use cloud LLM for complex queries
    return await _cloudLLM.generateResponse(prompt, context: context);
  }

  double _assessComplexity(String prompt) {
    // Simple complexity assessment
    final words = prompt.split(' ').length;
    final hasCode = prompt.contains('```');
    final hasMath = prompt.contains(RegExp(r'[\$\^_{}]'));
    
    double complexity = words / 100.0;
    if (hasCode) complexity += 0.3;
    if (hasMath) complexity += 0.2;
    
    return complexity.clamp(0.0, 1.0);
  }
}
```

### 5.3 Offline Data Management
```dart
// data/services/offline_service.dart
class OfflineService {
  static const String _conversationsBox = 'conversations';
  static const String _messagesBox = 'messages';
  static const String _pendingBox = 'pending_actions';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Conversation>(_conversationsBox);
    await Hive.openBox<Message>(_messagesBox);
    await Hive.openBox<Map>(_pendingBox);
  }

  Future<void> cacheMessage(Message message) async {
    final box = Hive.box<Message>(_messagesBox);
    await box.put(message.id, message);
  }

  Future<List<Message>> getCachedMessages(String conversationId) async {
    final box = Hive.box<Message>(_messagesBox);
    return box.values
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> queuePendingAction(Map<String, dynamic> action) async {
    final box = Hive.box<Map>(_pendingBox);
    await box.add(action);
  }

  Future<void> syncPendingActions() async {
    final box = Hive.box<Map>(_pendingBox);
    final actions = box.values.toList();
    
    for (final action in actions) {
      try {
        await _executePendingAction(action);
        await box.delete(action);
      } catch (e) {
        // Keep in queue for retry
      }
    }
  }
}
```

## 6. Testing & Deployment

### 6.1 Testing Strategy
```dart
// test/unit/chat_repository_test.dart
void main() {
  group('ChatRepository', () {
    late ChatRepository repository;
    late MockChatDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockChatDataSource();
      repository = ChatRepository(dataSource: mockDataSource);
    });

    test('should cache messages locally when sent', () async {
      final message = Message(
        id: '1',
        conversationId: 'conv1',
        senderId: 'user1',
        senderType: SenderType.human,
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      await repository.sendMessage(message);

      verify(mockDataSource.cacheMessage(message));
    });
  });
}

// test/widget/chat_screen_test.dart
void main() {
  testWidgets('ChatScreen displays messages correctly', (tester) async {
    final messages = [
      Message(id: '1', content: 'Hello', senderId: 'user1', /* ... */),
      Message(id: '2', content: 'Hi!', senderId: 'helpy1', /* ... */),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messagesProvider.overrideWith((ref) => messages),
        ],
        child: MaterialApp(home: ChatScreen()),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Hi!'), findsOneWidget);
  });
}
```

### 6.2 Build & Deployment
```bash
# Development builds
flutter run --debug

# Release builds
flutter build apk --release --split-per-abi
flutter build ios --release
flutter build web --release --web-renderer canvaskit

# Environment-specific builds
flutter build apk --release --dart-define=ENVIRONMENT=production
```

### 6.3 CI/CD Configuration
```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD
on:
  push:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
```

This specification provides a complete roadmap for implementing the Helpy Ninja frontend with Flutter, focusing on the multi-agent AI tutoring system, offline capabilities, and progressive development approach.