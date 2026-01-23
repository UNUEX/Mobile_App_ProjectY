// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yauctor_ai/core/router/app_router.dart';
import 'package:yauctor_ai/core/theme/app_theme.dart';
import 'package:yauctor_ai/core/utils/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Загружаем .env
    await dotenv.load(fileName: "assets/.env");

    // Логгируем загрузку ключа
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      Log.i('OpenRouter API Key loaded: ${apiKey.substring(0, 10)}...');
    } else {
      Log.w('OpenRouter API Key not found in .env file');
    }

    // Инициализируем Supabase
    await Supabase.initialize(
      url: 'https://aeuxnfamdwegompaqsdr.supabase.co',
      anonKey: 'sb_publishable_lOCc-Delx6ikV97blF3gJw_zmpiRaGj',
    );

    Log.i('Supabase initialized successfully');

    runApp(const ProviderScope(child: YauctorApp()));
  } catch (e, stackTrace) {
    Log.e('Failed to initialize app', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

class YauctorApp extends StatelessWidget {
  const YauctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yauctor',
      theme: AppTheme.light(),
      initialRoute: AppRouter.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
