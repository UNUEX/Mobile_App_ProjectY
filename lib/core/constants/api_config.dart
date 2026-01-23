// lib/core/constants/api_config.dart
class ApiConfig {
  static const String openRouterApiKey = String.fromEnvironment(
    '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',
    defaultValue: '', // В продакшене использовать .env
  );

  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1';
}
