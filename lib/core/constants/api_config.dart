// lib/core/constants/api_config.dart
class ApiConfig {
  static const String openRouterApiKey = String.fromEnvironment(
    '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',
    defaultValue: '', // В продакшене использовать .env
  );

  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1';
}
