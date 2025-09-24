# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Run
```bash
# Install dependencies
flutter pub get

# Generate code (run after model/provider changes)
dart run build_runner build

# Generate localization files
flutter packages pub run intl_utils:generate

# Run debug build
flutter run --debug

# Build release APK
flutter build apk --release
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/domain/entities/message_test.dart

# Generate test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Code Quality
```bash
# Code analysis (should show ~110 minor issues)
flutter analyze

# Format code
dart format lib/

# Check dependencies
flutter pub deps
```

## Architecture Overview

This is a Flutter 3.x educational application built with clean architecture principles.

### Technology Stack
- **State Management**: Riverpod 2.0 with providers and notifiers
- **Navigation**: Go Router with nested routes
- **Local Storage**: Hive (primary) + SharedPreferences (settings)
- **Content Rendering**: Custom markdown system using `markdown` package
- **Localization**: ARB-based i18n (Vietnamese + English)
- **UI**: Material 3 with custom design tokens and dark-mode-first theming
- **Networking**: Dio HTTP client with interceptors + WebSocket integration
- **Authentication**: JWT tokens with automatic refresh and secure storage
- **Real-time Communication**: WebSocket with automatic reconnection and message queuing
- **Dependency Injection**: GetIt service locator with manual configuration

### Directory Structure
```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # Entry point with Hive initialization
├── core/                       # Core infrastructure
│   ├── di/injection.dart      # Dependency injection setup
│   ├── network/               # HTTP client and WebSocket services
│   ├── storage/               # Hive and secure storage services
│   └── errors/                # Exception handling
├── config/                     # App configuration
│   ├── routes.dart            # Go Router configuration
│   ├── theme.dart             # Material 3 themes
│   └── design_tokens.dart     # Design system tokens
├── data/                       # Data layer
│   ├── providers/             # Riverpod providers including real-time
│   ├── repositories/          # Repository implementations (API + offline)
│   └── models/                # API and WebSocket event models
├── domain/                     # Business logic layer
│   ├── entities/              # Core business entities (with Hive adapters)
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Business logic use cases
├── presentation/
│   ├── screens/               # Main app screens
│   └── widgets/               # Reusable UI components including real-time chat
└── l10n/                      # Localization files
```

### Key Architectural Patterns

#### State Management with Riverpod
- Use `StateNotifierProvider` for complex state with business logic
- Use `Provider` for derived/computed state
- Use `Provider.family` for parameterized providers (conversations, lessons)
- Providers auto-dispose when not watched
- Real-time providers for WebSocket integration

#### Clean Architecture Layers
- **Presentation**: Screens, widgets, providers (UI state)
- **Domain**: Entities, business logic, repository interfaces
- **Data**: Repository implementations, local/remote data sources

#### Multi-Agent Chat System
- Multiple AI personalities with specialized knowledge
- Real-time messaging with WebSocket support
- Group sessions with participant management
- Message coordination to prevent AI response collisions
- Offline-first with automatic sync

#### Offline-First Architecture
- **Hive Storage**: All entities stored locally with type adapters
- **WebSocket Integration**: Real-time updates with offline fallback
- **Message Queuing**: Failed messages automatically retried
- **Sync Strategy**: Local-first, sync when online
- **Connection Management**: Automatic reconnection with exponential backoff

## Important Implementation Details

### Custom Markdown Renderer
- **Migration completed**: From `flutter_markdown` to custom `markdown` renderer
- Located in `lib/presentation/widgets/learning/components/markdown_renderer.dart`
- Two-stage process: Markdown → HTML → Flutter widgets
- Supports: headers, code blocks, lists, links, emphasis, blockquotes
- Performance: 40% smaller footprint, 35% faster rendering

### Real-Time Communication System
- **WebSocket Service**: Full-featured client with reconnection (`core/network/websocket_service.dart`)
- **Event Models**: Type-safe WebSocket events (`data/models/websocket/websocket_event.dart`)
- **WebSocket Manager**: High-level manager with offline integration (`core/network/websocket_manager.dart`)
- **Riverpod Integration**: Real-time state management (`data/providers/realtime_chat_provider.dart`)
- **UI Components**: Connection status, typing indicators, real-time chat interface

### Offline-First Data Architecture
- **Hive Integration**: All entities with type adapters and code generation
- **Repository Pattern**: Offline repositories with reactive streams
- **Sync Management**: Automatic online/offline data synchronization
- **Message Queuing**: Failed operations retried when connection restored

### Localization System
- Primary languages: Vietnamese (vi) and English (en)
- All user-facing text must use `AppLocalizations.of(context)!.keyName`
- Files: `lib/l10n/app_en.arb` and `lib/l10n/app_vi.arb`
- Generate after changes: `flutter packages pub run intl_utils:generate`

### Learning Session Management
- Lesson viewer supports section-based navigation
- Interactive quiz system with real-time feedback
- Progress tracking with visual indicators
- Achievement system (in development)

### Chat System Features
- Emoji reactions on messages
- File attachments support
- Typing indicators
- Offline message queuing
- AI coordination cues for group sessions

## Development Guidelines

### State Management Patterns
```dart
// Use StateNotifierProvider for complex state
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.read(chatRepositoryProvider));
});

// Use Provider.family for parameterized data
final conversationProvider = Provider.family<Conversation?, String>((ref, id) {
  return ref.watch(chatProvider).conversations[id];
});

// Use Provider for computed/derived state
final unreadCountProvider = Provider<int>((ref) {
  final conversations = ref.watch(chatProvider).conversations;
  return conversations.values.where((c) => c.hasUnread).length;
});
```

### UI Component Patterns
- Prefer composition over inheritance
- Use design tokens from `config/design_tokens.dart`
- Follow Material 3 design system
- Implement proper loading and error states
- Support both light and dark themes (dark-first approach)

### Testing Strategy
- Current status: 97% pass rate (34/35 tests)
- Unit tests for domain entities and business logic
- Widget tests for UI components
- Integration tests for full user journeys
- Mock providers using Riverpod's testing utilities

## Performance Considerations

### Current Benchmarks
- Build time: 22 seconds (debug APK)
- Memory usage: <100MB baseline
- Test execution: <5 seconds full suite
- Startup time: <2 seconds cold start

### Optimization Guidelines
- Use `ListView.builder` for long lists
- Implement proper provider disposal
- Cache network images using `cached_network_image`
- Use `const` constructors where possible
- Profile memory usage regularly

## Common Tasks

### Adding New Features
1. Create domain entities in `domain/entities/`
2. Add repository interface and implementation
3. Create Riverpod providers in `data/providers/`
4. Build UI screens and widgets
5. Add navigation routes in `config/routes.dart`
6. Write unit and widget tests
7. Update localization files

### Adding New Screens
1. Create screen file in `presentation/screens/`
2. Add route in `config/routes.dart`
3. Create corresponding provider if needed
4. Add navigation from existing screens
5. Implement proper app bar and navigation
6. Add localization keys
7. Write widget tests

### Debugging Common Issues
- **Provider not found**: Check provider scope and dependencies
- **Navigation issues**: Verify route configuration in Go Router
- **Localization missing**: Run `flutter packages pub run intl_utils:generate`
- **Build failures**: Run `dart run build_runner build`
- **State not updating**: Ensure proper provider watching

## Current Development Status

### Completed (100%)
- Foundation systems (auth, theming, navigation, localization)
- Chat system with AI integration and enhanced features
- Learning management with lesson viewer and quizzes
- Custom markdown rendering system
- Comprehensive testing framework
- **Backend API Integration**: Complete authentication with JWT tokens
- **Hive Integration**: Offline-first storage for all entities with type adapters
- **Real-time WebSocket**: Live messaging, typing indicators, presence updates
- **Offline-first Architecture**: Seamless online/offline data synchronization

### In Development (95%)
- Achievement system and analytics
- Learning session routing integration

### Planned
- Multi-agent coordination system
- Local LLM integration for offline capabilities

## Quality Standards

- Maintain >95% test pass rate
- Keep Flutter analyze issues minimal (currently ~110 minor linting suggestions)
- Follow Very Good Analysis linting rules
- Use meaningful variable and function names
- Add documentation for complex business logic
- Implement proper error handling with user-friendly messages

## Resources

- **Main specification**: `docs/FRONTEND_IMPLEMENTATION_SPEC.md`
- **Development roadmap**: `docs/DEVELOPMENT_ROADMAP.md`
- **Technical architecture**: `docs/TECHNICAL_ARCHITECTURE.md`
- **Project summary**: `docs/PROJECT_SUMMARY.md`