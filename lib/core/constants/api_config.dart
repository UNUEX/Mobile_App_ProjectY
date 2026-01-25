// lib/core/constants/api_config.dart
class ApiConfig {
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '', // В продакшене использовать .env
  );

  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1';
}
