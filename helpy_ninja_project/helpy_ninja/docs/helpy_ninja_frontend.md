# Helpy Ninja - Frontend Technical Documentation (Flutter)

## 1. Project Structure

```
helpy_ninja/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── app.dart                       # App configuration
│   ├── config/
│   │   ├── constants.dart             # App constants
│   │   ├── theme.dart                 # Theme configuration
│   │   ├── routes.dart                # Route definitions
│   │   └── environment.dart           # Environment configs
│   │
│   ├── core/
│   │   ├── di/                        # Dependency injection
│   │   │   └── injection.dart
│   │   ├── network/
│   │   │   ├── api_client.dart        # Dio configuration
│   │   │   ├── websocket_client.dart  # WebSocket management
│   │   │   └── interceptors.dart      # Network interceptors
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── helpers.dart
│   │   └── extensions/
│   │       ├── string_extensions.dart
│   │       └── datetime_extensions.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── student_profile_model.dart
│   │   │   │   └── parent_profile_model.dart
│   │   │   ├── helpy/
│   │   │   │   ├── helpy_model.dart
│   │   │   │   ├── helpy_personality_model.dart
│   │   │   │   └── helpy_config_model.dart
│   │   │   ├── chat/
│   │   │   │   ├── message_model.dart
│   │   │   │   ├── conversation_model.dart
│   │   │   │   └── group_session_model.dart
│   │   │   ├── learning/
│   │   │   │   ├── subject_model.dart
│   │   │   │   ├── curriculum_model.dart
│   │   │   │   ├── progress_model.dart
│   │   │   │   └── assessment_model.dart
│   │   │   └── subscription/
│   │   │       ├── plan_model.dart
│   │   │       └── payment_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   ├── chat_repository.dart
│   │   │   ├── helpy_repository.dart
│   │   │   ├── learning_repository.dart
│   │   │   └── subscription_repository.dart
│   │   │
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   ├── chat_remote_datasource.dart
│   │   │   │   └── learning_remote_datasource.dart
│   │   │   ├── local/
│   │   │   │   ├── cache_datasource.dart
│   │   │   │   ├── preferences_datasource.dart
│   │   │   │   └── offline_datasource.dart
│   │   │   └── ml/
│   │   │       ├── local_llm_datasource.dart
│   │   │       └── tflite_datasource.dart
│   │   │
│   │   └── services/
│   │       ├── websocket_service.dart
│   │       ├── notification_service.dart
│   │       ├── speech_service.dart
│   │       ├── connectivity_service.dart
│   │       └── background_service.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── helpy.dart
│   │   │   ├── message.dart
│   │   │   ├── subject.dart
│   │   │   └── progress.dart
│   │   ├── repositories/              # Repository interfaces
│   │   │   └── i_chat_repository.dart
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── login_usecase.dart
│   │       │   └── logout_usecase.dart
│   │       ├── chat/
│   │       │   ├── send_message_usecase.dart
│   │       │   └── join_group_usecase.dart
│   │       └── learning/
│   │           ├── get_progress_usecase.dart
│   │           └── submit_answer_usecase.dart
│   │
│   ├── presentation/
│   │   ├── providers/                 # Riverpod providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── chat_provider.dart
│   │   │   ├── helpy_provider.dart
│   │   │   ├── learning_provider.dart
│   │   │   └── settings_provider.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── onboarding/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── profile_setup_screen.dart
│   │   │   │   ├── subject_selection_screen.dart
│   │   │   │   └── helpy_customization_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── dashboard_tab.dart
│   │   │   │   ├── subjects_tab.dart
│   │   │   │   └── progress_tab.dart
│   │   │   ├── chat/
│   │   │   │   ├── chat_screen.dart
│   │   │   │   ├── group_chat_screen.dart
│   │   │   │   ├── chat_list_screen.dart
│   │   │   │   └── chat_settings_screen.dart
│   │   │   ├── learning/
│   │   │   │   ├── lesson_screen.dart
│   │   │   │   ├── practice_screen.dart
│   │   │   │   ├── assessment_screen.dart
│   │   │   │   └── whiteboard_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── settings_screen.dart
│   │   │   │   └── subscription_screen.dart
│   │   │   └── parent/
│   │   │       ├── parent_dashboard_screen.dart
│   │   │       └── child_progress_screen.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── loading_widget.dart
│   │   │   │   ├── error_widget.dart
│   │   │   │   ├── empty_widget.dart
│   │   │   │   └── custom_app_bar.dart
│   │   │   ├── chat/
│   │   │   │   ├── message_bubble.dart
│   │   │   │   ├── helpy_indicator.dart
│   │   │   │   ├── typing_indicator.dart
│   │   │   │   ├── chat_input.dart
│   │   │   │   └── participant_list.dart
│   │   │   ├── learning/
│   │   │   │   ├── math_renderer.dart
│   │   │   │   ├── code_editor.dart
│   │   │   │   ├── progress_chart.dart
│   │   │   │   └── subject_card.dart
│   │   │   └── animations/
│   │   │       ├── fade_animation.dart
│   │   │       └── slide_animation.dart
│   │   │
│   │   └── controllers/              # For complex widget logic
│   │       ├── chat_controller.dart
│   │       ├── whiteboard_controller.dart
│   │       └── audio_controller.dart
│   │
│   └── l10n/                          # Localization
│       ├── app_en.arb
│       └── app_vi.arb
│
├── assets/
│   ├── images/
│   │   ├── logo/
│   │   ├── illustrations/
│   │   └── avatars/
│   ├── animations/
│   │   └── lottie/
│   ├── fonts/
│   └── models/                        # TFLite models
│       └── phi3_mini.tflite
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
└── README.md
```

## 2. Data Models

### 2.1 User Models

```yaml
UserModel:
  id: String
  email: String
  username: String
  role: enum [student, parent, tutor, admin]
  profileComplete: bool
  createdAt: DateTime
  lastActive: DateTime
  subscription: SubscriptionModel?
  preferences: UserPreferences

StudentProfileModel:
  userId: String
  name: String
  age: int
  gender: String?
  location: LocationModel
  gradeLevel: String
  curriculum: enum [commonCore, vietnamese, ib, custom]
  subjects: List<SubjectModel>
  helpy: HelpyModel
  learningStyle: enum [visual, auditory, kinesthetic, mixed]
  goals: List<LearningGoal>
  strengths: List<String>
  weaknesses: List<String>
  parentIds: List<String>
```

### 2.2 Helpy Models

```yaml
HelpyModel:
  id: String
  name: String
  ownerId: String
  personality: HelpyPersonalityModel
  avatar: String
  voiceId: String?
  created: DateTime
  totalSessions: int
  relationshipDepth: int
  memories: List<MemoryModel>

HelpyPersonalityModel:
  baseArchetype: enum [enthusiastic, patient, strict, friendly, cool]
  enthusiasm: double (0-1)
  formality: double (0-1)
  humorLevel: double (0-1)
  teachingStyle: enum [socratic, direct, gamified, collaborative]
  customTraits: Map<String, dynamic>
  subjectPersonalities: Map<String, PersonalityOverride>
```

### 2.3 Chat Models

```yaml
MessageModel:
  id: String
  conversationId: String
  senderId: String
  senderType: enum [human, helpy]
  content: String
  contentType: enum [text, math, code, image, audio]
  timestamp: DateTime
  metadata: MessageMetadata
  reactions: List<Reaction>
  edited: bool
  editedAt: DateTime?

GroupSessionModel:
  id: String
  name: String
  subject: String
  participants: List<ParticipantModel>
  helpys: List<HelpyModel>
  messages: List<MessageModel>
  startTime: DateTime
  endTime: DateTime?
  sessionType: enum [studyGroup, classroom, peerTutoring]
  activeParticipants: int
  metadata: SessionMetadata

ParticipantModel:
  userId: String
  helpyId: String
  role: enum [leader, member, observer]
  joinedAt: DateTime
  lastActive: DateTime
  messageCount: int
  participationScore: double
```

### 2.4 Learning Models

```yaml
SubjectModel:
  id: String
  name: String
  category: enum [math, science, language, history, other]
  level: String
  curriculum: String
  isActive: bool
  schedule: ScheduleModel?
  currentTopic: String?
  progress: double
  lastStudied: DateTime
  totalHours: double
  helpyPersonalityOverride: PersonalityOverride?

ProgressModel:
  studentId: String
  subjectId: String
  overallProgress: double
  topicsCompleted: List<TopicProgress>
  strengths: List<String>
  weaknesses: List<String>
  recentAssessments: List<AssessmentResult>
  studyStreak: int
  totalStudyTime: Duration
  lastUpdated: DateTime
```

## 3. State Management (Riverpod)

### 3.1 Provider Structure

```yaml
Providers:
  # Auth Providers
  authStateProvider: StateNotifierProvider<AuthState>
  currentUserProvider: Provider<User?>
  isAuthenticatedProvider: Provider<bool>
  
  # Chat Providers
  chatListProvider: FutureProvider<List<Conversation>>
  currentChatProvider: StateNotifierProvider<ChatState>
  messagesProvider: StreamProvider<List<Message>>
  typingIndicatorProvider: StateProvider<Map<String, bool>>
  
  # Helpy Providers
  helpyProvider: StateNotifierProvider<HelpyState>
  helpyResponseProvider: FutureProvider<String>
  modelSelectionProvider: Provider<LLMModel>
  
  # Learning Providers
  subjectsProvider: FutureProvider<List<Subject>>
  currentSubjectProvider: StateProvider<Subject?>
  progressProvider: FutureProvider<Progress>
  
  # Group Session Providers
  groupSessionProvider: StateNotifierProvider<GroupSessionState>
  participantsProvider: StreamProvider<List<Participant>>
  groupMessagesProvider: StreamProvider<List<Message>>
  
  # Settings Providers
  themeProvider: StateProvider<ThemeMode>
  localeProvider: StateProvider<Locale>
  offlineModeProvider: StateProvider<bool>
  
  # Connection Providers
  connectivityProvider: StreamProvider<ConnectivityResult>
  websocketProvider: Provider<WebSocketChannel?>
```

### 3.2 State Classes

```yaml
AuthState:
  status: enum [initial, loading, authenticated, unauthenticated, error]
  user: User?
  error: String?

ChatState:
  status: enum [initial, loading, connected, disconnected, error]
  currentConversation: Conversation?
  messages: List<Message>
  isTyping: bool
  error: String?

HelpyState:
  status: enum [idle, thinking, responding, error]
  currentResponse: String?
  personality: HelpyPersonality
  memories: List<Memory>
  modelInUse: LLMModel

GroupSessionState:
  status: enum [initial, joining, active, ended, error]
  session: GroupSession?
  participants: List<Participant>
  myHelpy: Helpy?
  otherHelpys: List<Helpy>
  responseQueue: Queue<PendingResponse>
```

## 4. Navigation (Go Router)

### 4.1 Route Structure

```yaml
Routes:
  /: SplashScreen
  /onboarding:
    /welcome: WelcomeScreen
    /profile: ProfileSetupScreen
    /subjects: SubjectSelectionScreen
    /helpy: HelpyCustomizationScreen
  
  /auth:
    /login: LoginScreen
    /register: RegisterScreen
    /forgot-password: ForgotPasswordScreen
  
  /home: HomeScreen (ShellRoute)
    /dashboard: DashboardTab
    /subjects: SubjectsTab
    /progress: ProgressTab
  
  /chat:
    /list: ChatListScreen
    /:id: ChatScreen
    /group/:id: GroupChatScreen
    /settings/:id: ChatSettingsScreen
  
  /learning:
    /lesson/:id: LessonScreen
    /practice/:subjectId: PracticeScreen
    /assessment/:id: AssessmentScreen
    /whiteboard: WhiteboardScreen
  
  /profile:
    /: ProfileScreen
    /settings: SettingsScreen
    /subscription: SubscriptionScreen
  
  /parent:
    /dashboard: ParentDashboardScreen
    /child/:id: ChildProgressScreen
```

### 4.2 Route Guards

```yaml
Guards:
  AuthGuard: Redirects to login if not authenticated
  OnboardingGuard: Redirects to onboarding if profile incomplete
  SubscriptionGuard: Checks subscription status for premium features
  ParentGuard: Ensures parent role for parent routes
  OfflineGuard: Redirects to offline mode when disconnected
```

## 5. Services Architecture

### 5.1 WebSocket Service

```yaml
WebSocketService:
  Methods:
    - connect(url, token)
    - disconnect()
    - sendMessage(message)
    - joinGroup(groupId)
    - leaveGroup(groupId)
    - subscribeToMessages(conversationId)
    - handleReconnection()
  
  Events:
    - onMessage
    - onTyping
    - onPresence
    - onError
    - onReconnect
```

### 5.2 Local LLM Service

```yaml
LocalLLMService:
  Models:
    - Phi3Mini (500MB)
    - Llama3.2-1B (1GB)
    - SubjectSpecificModels
  
  Methods:
    - loadModel(modelPath)
    - generateResponse(prompt, context)
    - checkModelAvailability()
    - downloadModel(modelId)
    - clearCache()
    - optimizeForDevice()
```

### 5.3 Offline Service

```yaml
OfflineService:
  Capabilities:
    - cacheResponses()
    - syncWhenOnline()
    - queueMessages()
    - downloadContent()
    - manageCacheSize()
  
  Storage:
    - Hive boxes for structured data
    - SQLite for conversation history
    - File system for models and content
```

## 6. UI/UX Components

### 6.1 Chat Interface Components

```yaml
ChatComponents:
  MessageBubble:
    - Sender avatar/name
    - Message content (markdown support)
    - Timestamp
    - Helpy indicator
    - Read receipts
  
  ChatInput:
    - Text field with math/code support
    - Voice input button
    - Attachment button
    - Send button with loading state
  
  HelpyIndicator:
    - Shows which Helpy is speaking
    - Thinking animation
    - Model in use badge
```

### 6.2 Learning Interface Components

```yaml
LearningComponents:
  MathRenderer:
    - LaTeX rendering
    - Step-by-step solutions
    - Interactive equations
  
  Whiteboard:
    - Drawing tools
    - Shape recognition
    - Collaborative cursors
    - Save/share functionality
  
  ProgressVisualization:
    - Circular progress
    - Streak calendar
    - Topic mastery chart
    - Time spent graph
```

## 7. Platform-Specific Configurations

### 7.1 iOS Configuration

```yaml
iOS:
  Info.plist:
    - Microphone usage (speech input)
    - Camera usage (homework photos)
    - Photo library usage
    - Background modes (audio, fetch)
  
  Capabilities:
    - Push notifications
    - Background fetch
    - Audio background mode
```

### 7.2 Android Configuration

```yaml
Android:
  Permissions:
    - INTERNET
    - RECORD_AUDIO
    - CAMERA
    - WRITE_EXTERNAL_STORAGE
    - FOREGROUND_SERVICE
  
  Features:
    - Adaptive icons
    - Picture-in-picture for video
    - App shortcuts
```

### 7.3 Web Configuration

```yaml
Web:
  Features:
    - Responsive design
    - PWA support
    - Web Workers for heavy computation
    - IndexedDB for offline storage
  
  Optimizations:
    - Code splitting
    - Lazy loading
    - Service workers
```

## 8. Performance Optimizations

### 8.1 Rendering Optimizations

```yaml
Optimizations:
  - Const constructors everywhere possible
  - ListView.builder for long lists
  - Cached network images
  - Debounced search inputs
  - Memoized expensive computations
  - Virtual scrolling for chat history
```

### 8.2 State Optimizations

```yaml
StateOptimizations:
  - Selective widget rebuilds with select()
  - Family providers for parameterized state
  - AutoDispose for temporary providers
  - KeepAlive for important providers
  - Pagination for large datasets
```

## 9. Testing Structure

### 9.1 Test Organization

```yaml
TestStructure:
  Unit Tests:
    - Models serialization
    - Business logic
    - Utilities and helpers
    - Providers logic
  
  Widget Tests:
    - Individual widget behavior
    - Screen layouts
    - User interactions
    - Navigation flows
  
  Integration Tests:
    - Full user flows
    - API integration
    - WebSocket communication
    - Offline/online transitions
```

## 10. Build & Deployment

### 10.1 Flavors/Environments

```yaml
Environments:
  Development:
    - API: dev-api.helpy.ninja
    - WebSocket: ws://dev-ws.helpy.ninja
    - Debug mode enabled
  
  Staging:
    - API: staging-api.helpy.ninja
    - WebSocket: wss://staging-ws.helpy.ninja
    - Production-like environment
  
  Production:
    - API: api.helpy.ninja
    - WebSocket: wss://ws.helpy.ninja
    - Optimized builds
```

### 10.2 CI/CD Pipeline

```yaml
Pipeline:
  - Code analysis (flutter analyze)
  - Format check (flutter format)
  - Unit tests
  - Widget tests
  - Build APK/IPA
  - Integration tests
  - Deploy to stores
```