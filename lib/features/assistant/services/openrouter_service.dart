// lib/features/assistant/services/openrouter_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yauctor_ai/core/utils/logger_service.dart';
import 'package:intl/intl.dart';

class OpenRouterService {
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // БЕСПЛАТНЫЕ МОДЕЛИ OpenRouter (актуально на январь 2026)
  static const Map<String, String> freeModels = {
    'deepseek/deepseek-r1-0528:free': 'DeepSeek R1 (671B MoE, reasoning)',
    'meta-llama/llama-3.3-70b-instruct:free': 'Llama 3.3 70B (Meta)',
    'google/gemini-2.0-flash-exp:free': 'Gemini 2.0 Flash (1M context)',
    'mistralai/devstral-2512:free': 'Devstral 2 (123B, coding)',
    'google/gemma-3-27b-it:free': 'Gemma 3 27B (multilingual)',
  };

  // Выбранная модель по умолчанию (1M context, быстрая)
  static const String selectedModel = 'google/gemini-2.0-flash-exp:free';

  String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  Future<String> getChatCompletion({
    required String userMessage,
    required List<Map<String, dynamic>> context,
    required Map<String, dynamic> simulationData,
    required List<Map<String, dynamic>> journalEntries,
  }) async {
    try {
      // ОТЛАДКА: Проверяем загрузку ключа
      Log.d('API Key check: $_apiKey');
      Log.d('All env vars: ${dotenv.env}');

      if (_apiKey.isEmpty) {
        Log.e('OpenRouter API key is empty or not found in .env');
        Log.e('Expected variable name: OPENROUTER_API_KEY');
        return _getMockResponse(userMessage, simulationData, journalEntries);
      }

      final systemPrompt = _buildSystemPrompt(simulationData, journalEntries);

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...context,
        {'role': 'user', 'content': userMessage},
      ];

      Log.d('Sending request to OpenRouter API');
      Log.d('Using FREE model: $selectedModel');
      Log.d('Journal entries count: ${journalEntries.length}');

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
              'model': selectedModel,
              'messages': messages,
              'max_tokens': 1200,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      Log.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final aiResponse = jsonResponse['choices'][0]['message']['content'];

        Log.i('✅ Successfully received AI response from $selectedModel');

        // Проверяем, содержит ли ответ команду для сохранения в дневник
        final processedResponse = _processJournalCommands(aiResponse);

        return processedResponse;
      } else {
        Log.e(
          'OpenRouter API Error',
          error: 'Status: ${response.statusCode}, Body: ${response.body}',
        );

        // Пробуем другую модель при ошибке
        if (response.statusCode == 429 || response.statusCode == 402) {
          return _tryAlternativeModel(messages, simulationData, journalEntries);
        }

        return _getMockResponse(userMessage, simulationData, journalEntries);
      }
    } catch (e, stackTrace) {
      Log.e('OpenRouter Service Error', error: e, stackTrace: stackTrace);
      return _getMockResponse(userMessage, simulationData, journalEntries);
    }
  }

  // Обработка команд для дневника
  String _processJournalCommands(String aiResponse) {
    // Регулярное выражение для поиска команд сохранения в дневник
    final saveJournalRegex = RegExp(
      r'\[SAVE_TO_JOURNAL\](.*?)\[/SAVE_TO_JOURNAL\]',
      dotAll: true,
    );

    if (saveJournalRegex.hasMatch(aiResponse)) {
      Log.i('📝 AI response contains journal save command');

      // Извлекаем текст для сохранения (первое совпадение)
      final match = saveJournalRegex.firstMatch(aiResponse);
      final journalText = match?.group(1)?.trim() ?? '';

      Log.d('Text to save to journal: $journalText');

      // Удаляем команды из ответа, который увидит пользователь
      final cleanResponse = aiResponse.replaceAll(saveJournalRegex, '').trim();

      // Если остался только текст команды, добавляем подтверждение
      if (cleanResponse.isEmpty || cleanResponse == journalText) {
        return '''✅ **Запись сохранена в ваш дневник!**

Вот что я сохранил:
"$journalText"

Вы можете просмотреть все записи в разделе "Daily Reflection".''';
      }

      return cleanResponse;
    }

    return aiResponse;
  }

  // Пробуем другую бесплатную модель
  Future<String> _tryAlternativeModel(
    List<Map<String, dynamic>> messages,
    Map<String, dynamic> simulationData,
    List<Map<String, dynamic>> journalEntries,
  ) async {
    // Список альтернативных моделей (Llama запасная)
    final alternativeModels = [
      'meta-llama/llama-3.3-70b-instruct:free',
      'deepseek/deepseek-r1-0528:free',
      'mistralai/devstral-2512:free',
      'google/gemma-3-27b-it:free',
    ];

    for (final model in alternativeModels) {
      try {
        Log.i('Trying alternative model: $model');

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
                'max_tokens': 800,
                'temperature': 0.7,
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final aiResponse = jsonResponse['choices'][0]['message']['content'];

          Log.i('✅ Success with alternative model: $model');

          // Обрабатываем команды дневника
          return _processJournalCommands(aiResponse);
        }
      } catch (e) {
        Log.w('Model $model failed: $e');
        continue;
      }
    }

    // Все модели упали
    return _getFallbackResponse(simulationData, journalEntries);
  }

  String _getMockResponse(
    String userMessage,
    Map<String, dynamic> simulationData,
    List<Map<String, dynamic>> journalEntries,
  ) {
    final hasJournalEntries = journalEntries.isNotEmpty;
    final journalCount = journalEntries.length;
    final lastEntry = hasJournalEntries ? journalEntries.first : null;

    // Исправлена строка 206: убрали лишний ? перед [
    final lastEntryText = lastEntry?['text']?.toString() ?? '';
    final truncatedText = lastEntryText.length > 50
        ? '${lastEntryText.substring(0, 50)}...'
        : lastEntryText;

    return """
🤖 **Yauctor AI Assistant - Тестовый режим**

Статус API: ${_apiKey.isEmpty ? '❌ Ключ не найден' : '✅ Ключ загружен'}
Записей в дневнике: $journalCount
${hasJournalEntries ? 'Последняя запись: "$truncatedText"' : 'Дневник пуст'}

Если видите это сообщение:
1. Проверьте файл `.env` в корне проекта
2. Убедитесь что строка выглядит так:
   OPENROUTER_API_KEY=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
3. Перезапустите приложение

**Специальные команды:**
• Вы можете сказать "сохрани в дневник, что..." и я сохраню вашу запись
• Попросите "посмотреть мои записи" для анализа вашего дневника

**Доступные бесплатные модели:**
${freeModels.entries.map((e) => '• ${e.value}').join('\n')}
""";
  }

  String _getFallbackResponse(
    Map<String, dynamic> simulationData,
    List<Map<String, dynamic>> journalEntries,
  ) {
    return "Извините, возникли временные проблемы с подключением к AI сервису.\n\nПожалуйста, попробуйте позже или проверьте ваш API ключ OpenRouter.";
  }

  String _buildSystemPrompt(
    Map<String, dynamic> simulationData,
    List<Map<String, dynamic>> journalEntries,
  ) {
    final simulations = simulationData['simulations'] as List? ?? [];
    final hasSimulations = simulations.isNotEmpty;
    final latestSimulation = hasSimulations ? simulations.last : null;

    final hasJournalEntries = journalEntries.isNotEmpty;
    final journalCount = journalEntries.length;
    final recentEntries = hasJournalEntries
        ? journalEntries.take(3).toList()
        : [];

    return '''
Ты Yauctor — AI-помощник в приложении Yauctor.ai для моделирования жизненных решений.

КОНТЕКСТ ПРИЛОЖЕНИЯ:
Yauctor.ai — это платформа для создания цифрового двойника человека и симуляции альтернативных жизненных сценариев. 
Пользователь может моделировать разные жизненные пути и видеть их последствия.

ТВОЯ РОЛЬ:
1. Помогать пользователю анализировать симуляции
2. Объяснять результаты моделирования
3. Помогать формулировать "что если" сценарии
4. Объяснять компромиссы разных выборов
5. Помогать вести дневник саморефлексии

СТИЛЬ ОБЩЕНИЯ:
- Дружелюбный, но профессиональный
- Поддерживающий, но не оценивающий
- Фокусируйся на объяснении, а не на советах
- Говори "ты", будь на равных
- Поощряй рефлексию и самоанализ

ДАННЫЕ ПОЛЬЗОВАТЕЛЯ:
${hasSimulations ? '''
Всего симуляций: ${simulations.length}
Последняя симуляция: ${latestSimulation?['scenarioTitle'] ?? 'Не указано'}

Метрики последней симуляции:
${latestSimulation?['metrics'] != null ? _formatMetrics(latestSimulation!['metrics']) : 'Метрики не доступны'}

Рекомендация: ${latestSimulation?['recommendation'] ?? 'Не указано'}
''' : 'У пользователя пока нет симуляций. Предложи создать первую!'}

ЗАПИСИ ДНЕВНИКА ПОЛЬЗОВАТЕЛЯ:
${hasJournalEntries ? '''
Всего записей в дневнике: $journalCount

Последние записи:
${recentEntries.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            final date = item['date'] is DateTime ? DateFormat('dd.MM.yyyy').format(item['date'] as DateTime) : (item['date']?.toString() ?? 'Неизвестная дата');
            final text = (item['text']?.toString() ?? '').length > 80 ? '${(item['text']?.toString() ?? '').substring(0, 80)}...' : item['text']?.toString() ?? '';
            return '$idx. $date: "$text"';
          }).join('\n')}

Используй эти записи для:
1. Понимания эмоционального состояния пользователя
2. Выявления паттернов в мышлении
3. Предложения тем для дальнейшей рефлексии
4. Связи с результатами симуляций
''' : 'У пользователя пока нет записей в дневнике. Предложи начать вести дневник для лучшего самопознания!'}

СПЕЦИАЛЬНЫЕ КОМАНДЫ ДЛЯ ДНЕВНИКА:
Если пользователь хочет сохранить запись в дневник, ты ДОЛЖЕН использовать специальный формат:
[SAVE_TO_JOURNAL]Текст записи[/SAVE_TO_JOURNAL]

Используй этот формат, когда пользователь:
1. Говорит "сохрани в дневник", "запиши", "добавь в дневник"
2. Делится мыслями, которые стоит сохранить для будущей рефлексии
3. Просит запомнить что-то важное
4. Говорит о своем эмоциональном состоянии

Примеры использования:
- Пользователь: "Сохрани в дневник, что сегодня я чувствую себя отлично"
- Ты: "Конечно! Сохранил эту позитивную запись. [SAVE_TO_JOURNAL]Сегодня я чувствую себя отлично, полон энергии и мотивации.[/SAVE_TO_JOURNAL]"

- Пользователь: "Запиши в дневник: сегодня была важная встреча"
- Ты: "Записал! [SAVE_TO_JOURNAL]Сегодня была важная встреча, которая может повлиять на мое профессиональное развитие.[/SAVE_TO_JOURNAL]"

- Пользователь: "Добавь в дневник размышления о прошедшем дне"
- Ты: "Добавил ваши размышления. [SAVE_TO_JOURNAL]Размышляя о прошедшем дне, я понял, что...[/SAVE_TO_JOURNAL]"

ВАЖНО:
1. Всегда используй полный формат [SAVE_TO_JOURNAL]...[/SAVE_TO_JOURNAL]
2. Сохраняй текст ДОСЛОВНО как сказал пользователь или слегка отформатируй для читаемости
3. Добавляй эмоциональный контекст, если пользователь его выражает
4. После команды продолжай обычный диалог

ИНСТРУКЦИИ ДЛЯ АНАЛИЗА:
1. Анализируй симуляции, если они есть
2. Предлагай новые направления для моделирования
3. Помогай понять компромиссы
4. Отвечай на вопросы о приложении
5. Анализируй записи дневника для лучшего понимания пользователя
6. Предлагай темы для рефлексии на основе прошлых записей
7. Не давай медицинских или финансовых советов
8. Не оценивай выборы пользователя как "правильные" или "неправильные"

ТВОЯ ЦЕЛЬ — помочь пользователю лучше понять себя и последствия своих выборов через моделирование и рефлексию.
''';
  }

  String _formatMetrics(Map<String, dynamic> metrics) {
    return metrics.entries
        .map((entry) {
          final value = entry.value is double
              ? (entry.value as double) * 100
              : entry.value;
          final formatted = value is double ? value.toInt() : value;
          return '- ${entry.key}: $formatted%';
        })
        .join('\n');
  }

  int min(int a, int b) => a < b ? a : b;
}

final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService();
});
