// lib/features/assistant/services/ai_assistant_commands.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yauctor_ai/core/router/app_router.dart';
import '../../journey/screens/life_simulation_screen.dart';
import '../../journey/providers/life_simulation_provider.dart';
import '../../journey/models/life_simulation.dart';

/// Команды для AI Assistant, связанные с симуляциями
class SimulationCommands {
  /// Проверяет, является ли сообщение пользователя командой на симуляцию
  static bool isSimulationCommand(String message) {
    final lowercaseMsg = message.toLowerCase().trim();

    final triggers = [
      'проведи симуляцию',
      'запусти симуляцию',
      'начать симуляцию',
      'симуляция жизни',
      'симулируй',
      'хочу симуляцию',
      'life simulation',
      'simulate my life',
      'сделай симуляцию',
      'пройти симуляцию',
    ];

    return triggers.any((trigger) => lowercaseMsg.contains(trigger));
  }

  /// Проверяет, запрашивает ли пользователь информацию о прошлых симуляциях
  static bool isSimulationHistoryRequest(String message) {
    final lowercaseMsg = message.toLowerCase().trim();

    final triggers = [
      'мои симуляции',
      'история симуляций',
      'прошлые симуляции',
      'покажи симуляции',
      'что было в симуляциях',
      'результаты симуляций',
      'посмотреть симуляции',
      'какие симуляции были',
    ];

    return triggers.any((trigger) => lowercaseMsg.contains(trigger));
  }

  /// Навигация к экрану симуляции
  static void navigateToSimulation(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LifeSimulationScreen()));
  }

  /// Навигация к истории (Journey)
  static void navigateToJourney(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.journey);
  }

  /// Генерация контекста для AI на основе прошлых симуляций
  static Future<String> generateSimulationContext(WidgetRef ref) async {
    final simulationsAsync = ref.read(lifeSimulationsProvider);

    return simulationsAsync.when(
      data: (simulations) {
        if (simulations.isEmpty) {
          return '''
Контекст симуляций: У пользователя пока нет завершенных симуляций жизненного пути.
Это отличная возможность предложить начать первую симуляцию для понимания своих ценностей и целей.
''';
        }

        final latest = simulations.first;
        final stats = _calculateStats(simulations);

        return '''
Контекст симуляций пользователя:
- Всего симуляций: ${simulations.length}
- Последняя симуляция: "${latest.title}" (${_formatDate(latest.createdAt)})
- Средний балл готовности: ${stats['avgScore']}%
- Эмоциональный тон последней: ${latest.emotionalTone ?? 'не определен'}
- Активные темы: ${latest.tags?.join(', ') ?? 'не указаны'}

Краткое резюме последней симуляции:
${_truncateSummary(latest.summary)}

Используй эту информацию для персонализированных рекомендаций.
''';
      },
      loading: () => 'Загрузка данных симуляций...',
      error: (_, _) => 'Ошибка загрузки контекста симуляций',
    );
  }

  /// Генерация ответа AI для команды симуляции
  static String generateSimulationResponse({
    required bool hasSimulations,
    int simulationCount = 0,
  }) {
    if (!hasSimulations) {
      return '''
🎯 Отлично! Симуляция жизненного пути поможет вам:

✨ Определить ключевые ценности и приоритеты
📊 Оценить текущий уровень готовности к изменениям
🚀 Получить персонализированные рекомендации
📈 Увидеть свой прогресс в виде красивой временной линии

Симуляция займет всего 5-7 минут. Вы ответите на несколько важных вопросов, а я помогу вам проанализировать результаты и составить план действий.

Готовы начать? Нажмите кнопку "Начать симуляцию" ниже! 👇
''';
    } else {
      return '''
Прекрасно! Вы уже прошли $simulationCount ${_getSimulationWord(simulationCount)}. 

Новая симуляция поможет:
• Отследить изменения в ваших приоритетах
• Зафиксировать новый этап развития
• Сравнить прогресс с предыдущими результатами

Каждая симуляция становится вехой на вашем пути. Готовы добавить новую главу в свою историю?
''';
    }
  }

  /// Генерация ответа AI для запроса истории симуляций
  static Future<String> generateHistoryResponse(WidgetRef ref) async {
    final simulationsAsync = ref.read(lifeSimulationsProvider);

    return simulationsAsync.when(
      data: (simulations) {
        if (simulations.isEmpty) {
          return '''
📭 У вас пока нет завершенных симуляций. 

Хотите начать свой первый путь самопознания? Симуляция поможет вам лучше понять свои цели и ценности.
''';
        }

        final titles = simulations.take(3).map((s) => s.title).toList();
        final titlesStr = titles.map((t) => '• $t').join('\n');

        return '''
📖 Ваша история развития включает ${simulations.length} ${_getSimulationWord(simulations.length)}:

$titlesStr
${simulations.length > 3 ? '... и еще ${simulations.length - 3}' : ''}

Каждая симуляция отражает важный этап вашего пути. Хотите посмотреть детали или начать новую?
''';
      },
      loading: () => '⏳ Загружаю вашу историю симуляций...',
      error: (_, _) => '⚠️ Ошибка загрузки истории симуляций',
    );
  }

  // Вспомогательные методы

  static Map<String, dynamic> _calculateStats(
    List<LifeSimulation> simulations,
  ) {
    if (simulations.isEmpty) {
      return {'avgScore': '0'};
    }

    double totalScore = 0;
    int count = 0;

    for (final sim in simulations) {
      final score = sim.results['totalScore'] as double?;
      if (score != null) {
        totalScore += score;
        count++;
      }
    }

    return {
      'avgScore': count > 0
          ? ((totalScore / count) * 100).toStringAsFixed(0)
          : '0',
    };
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'сегодня';
    if (diff.inDays == 1) return 'вчера';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} нед. назад';

    return '${date.day}.${date.month}.${date.year}';
  }

  static String _getSimulationWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'симуляцию';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'симуляции';
    }
    return 'симуляций';
  }

  static String _truncateSummary(String summary) {
    if (summary.length <= 150) return summary;
    return '${summary.substring(0, 150)}...';
  }
}

/// Widget для отображения кнопки действия в чате AI
class SimulationActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const SimulationActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.auto_awesome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
