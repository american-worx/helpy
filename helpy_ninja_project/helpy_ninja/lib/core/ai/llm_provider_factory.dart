import '../../domain/repositories/i_llm_repository.dart';
import 'providers/mock_llm_repository.dart';
import 'providers/openai_llm_repository.dart';
import 'providers/anthropic_llm_repository.dart';
import 'providers/local_llm_repository.dart';

/// Factory for creating LLM repository instances based on configuration
class LlmProviderFactory {
  static const String _defaultProvider = 'mock';

  /// Available LLM providers
  static const Map<String, String> availableProviders = {
    'mock': 'Mock LLM (for development/testing)',
    'openai': 'OpenAI GPT models',
    'anthropic': 'Anthropic Claude models',
    'local': 'Local LLM models (TensorFlow Lite)',
  };

  /// Create an LLM repository instance based on provider type
  static Future<ILlmRepository> create({
    String? provider,
    Map<String, dynamic>? config,
  }) async {
    final selectedProvider = provider ?? _defaultProvider;
    final providerConfig = config ?? <String, dynamic>{};

    switch (selectedProvider.toLowerCase()) {
      case 'openai':
        return OpenAiLlmRepository(config: providerConfig);
      case 'anthropic':
        return AnthropicLlmRepository(config: providerConfig);
      case 'local':
        return LocalLlmRepository(config: providerConfig);
      case 'mock':
      default:
        return MockLlmRepository(config: providerConfig);
    }
  }

  /// Get default provider name
  static String get defaultProvider => _defaultProvider;

  /// Check if a provider is available
  static bool isProviderAvailable(String provider) {
    return availableProviders.containsKey(provider.toLowerCase());
  }

  /// Get provider display name
  static String getProviderDisplayName(String provider) {
    return availableProviders[provider.toLowerCase()] ?? 'Unknown Provider';
  }

  /// Auto-detect the best available provider
  static Future<String> detectBestProvider() async {
    // Check providers in order of preference
    const preferenceOrder = ['anthropic', 'openai', 'local', 'mock'];

    for (final provider in preferenceOrder) {
      try {
        final repository = await create(provider: provider);
        final isAvailable = await repository.isAvailable();
        if (isAvailable) {
          return provider;
        }
      } catch (e) {
        // Continue to next provider
        continue;
      }
    }

    // Fallback to mock
    return 'mock';
  }
}

/// Configuration class for LLM providers
class LlmProviderConfig {
  final String provider;
  final String? apiKey;
  final String? baseUrl;
  final String? model;
  final Map<String, dynamic>? additionalSettings;

  const LlmProviderConfig({
    required this.provider,
    this.apiKey,
    this.baseUrl,
    this.model,
    this.additionalSettings,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'model': model,
        'additionalSettings': additionalSettings,
      };

  factory LlmProviderConfig.fromJson(Map<String, dynamic> json) => LlmProviderConfig(
        provider: json['provider'],
        apiKey: json['apiKey'],
        baseUrl: json['baseUrl'],
        model: json['model'],
        additionalSettings: json['additionalSettings'],
      );

  LlmProviderConfig copyWith({
    String? provider,
    String? apiKey,
    String? baseUrl,
    String? model,
    Map<String, dynamic>? additionalSettings,
  }) {
    return LlmProviderConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// Default configuration for development
  static const LlmProviderConfig development = LlmProviderConfig(
    provider: 'mock',
    model: 'mock-educational-v1',
  );

  /// Configuration for OpenAI
  static LlmProviderConfig openai({
    required String apiKey,
    String model = 'gpt-3.5-turbo',
  }) {
    return LlmProviderConfig(
      provider: 'openai',
      apiKey: apiKey,
      model: model,
      baseUrl: 'https://api.openai.com/v1',
    );
  }

  /// Configuration for Anthropic Claude
  static LlmProviderConfig anthropic({
    required String apiKey,
    String model = 'claude-3-sonnet-20240229',
  }) {
    return LlmProviderConfig(
      provider: 'anthropic',
      apiKey: apiKey,
      model: model,
      baseUrl: 'https://api.anthropic.com/v1',
    );
  }

  /// Configuration for local models
  static LlmProviderConfig local({
    String model = 'phi-3-mini',
    String? modelPath,
  }) {
    return LlmProviderConfig(
      provider: 'local',
      model: model,
      additionalSettings: {
        'modelPath': modelPath,
        'useGPU': true,
        'maxContextLength': 2048,
      },
    );
  }
}

/// LLM provider registry for managing multiple providers
class LlmProviderRegistry {
  final Map<String, ILlmRepository> _providers = {};
  final Map<String, LlmProviderConfig> _configs = {};

  /// Register a provider
  Future<void> registerProvider(
    String name,
    LlmProviderConfig config,
  ) async {
    final repository = await LlmProviderFactory.create(
      provider: config.provider,
      config: config.toJson(),
    );

    _providers[name] = repository;
    _configs[name] = config;
  }

  /// Get a registered provider
  ILlmRepository? getProvider(String name) {
    return _providers[name];
  }

  /// Get all registered provider names
  List<String> getRegisteredProviders() {
    return _providers.keys.toList();
  }

  /// Get provider configuration
  LlmProviderConfig? getProviderConfig(String name) {
    return _configs[name];
  }

  /// Remove a provider
  void removeProvider(String name) {
    _providers.remove(name);
    _configs.remove(name);
  }

  /// Clear all providers
  void clearProviders() {
    _providers.clear();
    _configs.clear();
  }

  /// Test all registered providers
  Future<Map<String, bool>> testAllProviders() async {
    final results = <String, bool>{};

    for (final entry in _providers.entries) {
      try {
        final isAvailable = await entry.value.testConnection();
        results[entry.key] = isAvailable;
      } catch (e) {
        results[entry.key] = false;
      }
    }

    return results;
  }
}