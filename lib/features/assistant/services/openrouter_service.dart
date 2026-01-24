// lib/features/assistant/services/openrouter_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yauctor_ai/core/utils/logger_service.dart';
import 'package:yauctor_ai/features/assistant/services/ai_assistant_commands.dart';
import 'package:yauctor_ai/features/home/providers/daily_reflection_provider.dart';

// Добавьте этот импорт вверху файла
import '../../journey/providers/life_simulation_provider.dart';

class OpenRouterService {
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String defaultModel = 'google/gemini-2.0-flash-exp:free';

  static const List<String> fallbackModels = [
    'meta-llama/llama-3.3-70b-instruct:free',
    'mistralai/devstral-2512:free',
    'google/gemma-3-27b-it:free',
  ];

  String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  // Добавьте ref в параметры класса или метода
  Future<String> getChatCompletion({
    required String userMessage,
    required List<Map<String, dynamic>> context,
    required WidgetRef ref, // Добавлен ref для доступа к провайдерам
    Map<String, dynamic>? simulationData,
    List<Map<String, dynamic>>? journalEntries,
  }) async {
    if (_apiKey.isEmpty) {
      Log.w('OpenRouter API key not found, using mock response');
      return _getMockResponse(userMessage);
    }

    // Получаем данные симуляций через провайдер
    final simulationData = await _getSimulationData(ref);
    final journalEntries = _getJournalEntries(ref);

    final systemPrompt = _buildSystemPrompt(simulationData, journalEntries);

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...context,
      {'role': 'user', 'content': userMessage},
    ];

    // Пробуем основную модель
    String? response = await _tryModel(defaultModel, messages);

    // Если не сработала, пробуем альтернативные
    if (response == null) {
      for (final model in fallbackModels) {
        Log.i('Trying fallback model: $model');
        response = await _tryModel(model, messages);
        if (response != null) break;
      }
    }

    return response ?? _getFallbackResponse();
  }

  // Новый метод для получения данных симуляций
  Future<Map<String, dynamic>> _getSimulationData(WidgetRef ref) async {
    try {
      final simulationsAsync = await ref.read(lifeSimulationsProvider.future);

      final simulationsJson = simulationsAsync
          .map(
            (sim) => ({
              'id': sim.id,
              'title': sim.title,
              'createdAt': sim.createdAt.toIso8601String(),
              'results': sim.results,
              'summary': sim.summary,
              'emotionalTone': sim.emotionalTone,
              'tags': sim.tags,
            }),
          )
          .toList();

      return {
        'simulations': simulationsJson,
        'hasSimulations': simulationsJson.isNotEmpty,
        'simulationCount': simulationsJson.length,
        'latestSimulation': simulationsJson.isNotEmpty
            ? simulationsJson.first
            : null,
      };
    } catch (e) {
      Log.e('Error getting simulation data', error: e);
      return {
        'simulations': [],
        'hasSimulations': false,
        'simulationCount': 0,
        'latestSimulation': null,
      };
    }
  }

  // Новый метод для получения записей журнала
  List<Map<String, dynamic>> _getJournalEntries(WidgetRef ref) {
    try {
      final reflections = ref.read(formattedReflectionsProvider);
      return reflections
          .map(
            (r) => ({
              'id': r.id,
              'text': r.text,
              'date': r.date,
              'emotion': r.emotion,
            }),
          )
          .toList();
    } catch (e) {
      Log.e('Error getting journal entries', error: e);
      return [];
    }
  }

  Future<String?> _tryModel(
    String model,
    List<Map<String, dynamic>> messages,
  ) async {
    try {
      Log.d('Sending request to model: $model');

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://yauctor.ai',
              'X-Title': 'Yauctor AI Assistant',
            },
            body: json.encode({
              'model': model,
              'messages': messages,
              'max_tokens': 300,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final aiResponse = jsonResponse['choices'][0]['message']['content'];
        Log.i('✅ Success from model: $model');
        return aiResponse;
      } else if (response.statusCode == 429) {
        Log.w('Model $model rate limited (429)');
        return null;
      } else {
        Log.w('Model $model failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Log.w('Model $model error: $e');
      return null;
    }
  }

  String _getMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Проверка команд симуляции в тестовом режиме
    if (SimulationCommands.isSimulationCommand(lowerMessage)) {
      return '''
🎯 Тестовая команда симуляции распознана!

В рабочем режиме я бы предложил вам начать симуляцию жизненного пути. 
Добавьте OPENROUTER_API_KEY в .env файл для полной функциональности.
''';
    }

    if (SimulationCommands.isSimulationHistoryRequest(lowerMessage)) {
      return '''
📖 Тестовая команда истории симуляций распознана!

В рабочем режиме я бы показал вам все ваши пройденные симуляции и прогресс.
''';
    }

    if (lowerMessage.contains('привет') || lowerMessage.contains('hello')) {
      return "Привет! Я в тестовом режиме. Добавьте API ключ для полной функциональности.";
    }

    if (lowerMessage.contains('сохрани') && lowerMessage.contains('дневник')) {
      return "Команда сохранения в дневник обрабатывается отдельно.\n(Для работы AI нужен API ключ в .env)";
    }

    return "Режим тестирования. Добавьте OPENROUTER_API_KEY в .env файл.";
  }

  String _getFallbackResponse() {
    return "Сервис AI временно недоступен. Попробуйте позже или проверьте интернет.";
  }

  String _buildSystemPrompt(
    Map<String, dynamic> simulationData,
    List<Map<String, dynamic>> journalEntries,
  ) {
    final simulationCount = simulationData['simulationCount'] as int? ?? 0;
    final journalCount = journalEntries.length;

    return '''
Ты Yauctor — AI-помощник для личностного роста и саморазвития.

ОТВЕЧАЙ КРАТКО. 1-2 предложения.

КОНТЕКСТ ПОЛЬЗОВАТЕЛЯ:
• Симуляций жизненного пути: $simulationCount ${simulationCount == 0 ? '(нет)' : ''}
• Записей в дневнике: $journalCount

СПЕЦИАЛЬНЫЕ КОМАНДЫ:
1. Если пользователь хочет симуляцию (спросит "проведи симуляцию", "хочу симуляцию" и т.д.):
   - Объясни пользу симуляции
   - Предложи начать
   - НЕ проводи симуляцию в чате - отправляй на специальный экран

2. Если спрашивает про прошлые симуляции ("мои симуляции", "история симуляций"):
   - Расскажи сколько их было
   - Предложи посмотреть в разделе Journey
   - Дай краткую сводку

ПРАВИЛА ОБЩЕНИЯ:
1. Отвечай кратко и по делу
2. Не философствуй без необходимости
3. Будь поддерживающим и мотивирующим
4. Для технических вопросов по симуляциям - направляй в соответствующие разделы

ПРИМЕРЫ ОТВЕТОВ:
Пользователь: "проведи симуляцию"
Ты: "Отлично! Симуляция поможет понять ваши ценности и цели. Начнем?"

Пользователь: "какие у меня симуляции?"
Ты: "У вас $simulationCount симуляций. Хотите посмотреть подробности в разделе Journey?"

Пользователь: "хочу понять свои цели"
Ты: "Симуляция - отличный способ! Она задаст важные вопросы о ценностях и поможет составить план."
''';
  }
}

final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService();
});

// Добавьте этот провайдер для доступа к количеству симуляций
final simulationCountProvider = Provider<int>((ref) {
  final simulations = ref.watch(lifeSimulationsProvider);
  return simulations.when(
    data: (data) => data.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});
