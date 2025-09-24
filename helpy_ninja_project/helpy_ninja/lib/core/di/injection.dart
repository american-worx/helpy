import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/hive_repository_base.dart';
import '../../core/network/websocket_service.dart';
import '../../core/network/websocket_manager.dart';
import '../../core/sync/sync_service.dart';
import '../../data/repositories/offline_chat_repository_impl.dart';
import '../../data/repositories/offline_lesson_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/repositories/i_llm_repository.dart';
import '../ai/llm_provider_factory.dart';
import '../ai/streaming_service.dart';

final GetIt getIt = GetIt.instance;

/// Configure dependencies manually (until build_runner generates config)
void configureDependencies() {
  // Core services
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<ApiClient>(ApiClient(getIt<SecureStorage>()));
  
  // Hive repositories - will be available after HiveService.init()
  getIt.registerLazySingleton<HiveUserRepository>(() => HiveUserRepository());
  getIt.registerLazySingleton<HiveConversationRepository>(() => HiveConversationRepository());
  getIt.registerLazySingleton<HiveMessageRepository>(() => HiveMessageRepository());
  getIt.registerLazySingleton<HiveLessonRepository>(() => HiveLessonRepository());
  getIt.registerLazySingleton<HiveLearningSessionRepository>(() => HiveLearningSessionRepository());
  
  // WebSocket services
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService(getIt<SecureStorage>()));
  getIt.registerLazySingleton<WebSocketManager>(() => WebSocketManager.create());
  
  // Offline repositories
  getIt.registerLazySingleton<OfflineChatRepositoryImpl>(() => OfflineChatRepositoryImpl());
  getIt.registerLazySingleton<OfflineLessonRepositoryImpl>(() => OfflineLessonRepositoryImpl());
  
  // Sync service
  getIt.registerLazySingleton<SyncService>(() => SyncService.create());

  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt<ApiClient>(), getIt<SecureStorage>()),
  );

  // Use Cases - Authentication
  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<IAuthRepository>()),
  );

  // LLM Services - Register AI services for educational chat
  _configureLLMServices();
}

/// Configure LLM and AI services
void _configureLLMServices() {
  // Initialize Enhanced AI Service with default configuration
  // This will be initialized when first used
  getIt.registerLazySingletonAsync<ILlmRepository>(() async {
    return await LlmProviderFactory.create(provider: 'mock');
  });
  
  // Register streaming service
  getIt.registerLazySingletonAsync<StreamingService>(() async {
    final llmRepository = await getIt.getAsync<ILlmRepository>();
    return StreamingService(llmRepository);
  });
}

/// Reset all dependencies (useful for testing)
void resetDependencies() {
  getIt.reset();
}

/// Register test dependencies (for testing)
void configureTestDependencies() {
  // Test-specific configurations will be added here
}