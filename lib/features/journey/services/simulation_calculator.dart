// lib/features/journey/services/simulation_calculator.dart
import 'package:uuid/uuid.dart';
import '../models/life_simulation.dart';

class SimulationCalculator {
  static const Uuid _uuid = Uuid();

  // Основной метод обработки симуляции
  static LifeSimulation processSimulation({
    required String userId,
    required Map<String, dynamic> answers,
  }) {
    final results = _calculateResults(answers);
    final summary = _generateSummary(answers, results);
    final emotionalTone = _detectEmotionalTone(answers);
    final tags = _generateTags(answers, results);
    final title = _generateTitle(answers, results);

    return LifeSimulation(
      id: _uuid.v4(), // Правильный UUID v4 формат
      userId: userId,
      title: title,
      answers: answers,
      results: results,
      summary: summary,
      createdAt: DateTime.now(),
      emotionalTone: emotionalTone,
      tags: tags,
    );
  }

  // Расчет результатов на основе ответов
  static Map<String, dynamic> _calculateResults(Map<String, dynamic> answers) {
    final categories = <Map<String, dynamic>>[];

    // Анализ ценностей
    if (answers['values'] != null) {
      final values = answers['values'] as List;
      categories.add({
        'category': 'Ценности',
        'score': _scoreValues(values),
        'insight': _getValuesInsight(values),
        'recommendation': _getValuesRecommendation(values),
        'strengths': _getValuesStrengths(values),
        'growthAreas': _getValuesGrowthAreas(values),
      });
    }

    // Анализ временного горизонта
    if (answers['time_horizon'] != null) {
      final horizon = answers['time_horizon'] as String;
      categories.add({
        'category': 'Планирование',
        'score': _scoreTimeHorizon(horizon),
        'insight': _getTimeHorizonInsight(horizon),
        'recommendation': _getTimeHorizonRecommendation(horizon),
      });
    }

    // Анализ текущего состояния
    if (answers['current_state'] != null) {
      final state = int.parse(answers['current_state'].toString());
      categories.add({
        'category': 'Текущее состояние',
        'score': state / 10.0,
        'insight': _getCurrentStateInsight(state),
        'recommendation': _getCurrentStateRecommendation(state),
      });
    }

    // Анализ готовности к вызовам
    if (answers['challenge'] != null) {
      final challenge = answers['challenge'] as String;
      categories.add({
        'category': 'Готовность к росту',
        'score': _scoreChallengeReadiness(challenge),
        'insight': _getChallengeInsight(challenge),
        'recommendation': _getChallengeRecommendation(challenge),
      });
    }

    // Общий score
    final totalScore = categories.isEmpty
        ? 0.0
        : categories.map((c) => c['score'] as double).reduce((a, b) => a + b) /
              categories.length;

    return {
      'categories': categories,
      'totalScore': totalScore,
      'readinessLevel': _getReadinessLevel(totalScore),
      'nextSteps': _generateNextSteps(answers, totalScore),
    };
  }

  // Вспомогательные методы для расчета scores
  static double _scoreValues(List values) {
    // Если приоритеты расставлены осознанно - высокий балл
    return values.length >= 3 ? 0.85 : 0.6;
  }

  static double _scoreTimeHorizon(String horizon) {
    if (horizon.contains('10+')) return 0.95;
    if (horizon.contains('3-5')) return 0.85;
    if (horizon.contains('1 год')) return 0.75;
    return 0.65;
  }

  static double _scoreChallengeReadiness(String challenge) {
    final highImpact = [
      'Выйти из зоны комфорта',
      'Преодолеть страх',
      'Начать проект мечты',
    ];
    return highImpact.any((h) => challenge.contains(h)) ? 0.9 : 0.75;
  }

  // Генерация инсайтов
  static String _getValuesInsight(List values) {
    if (values.isEmpty) return 'Ценности не определены';
    final primary = values.first;
    return 'Ваша главная ценность - "$primary". Это компас для принятия решений.';
  }

  static String _getTimeHorizonInsight(String horizon) {
    if (horizon.contains('10+')) {
      return 'Долгосрочное видение помогает делать правильный выбор сегодня.';
    } else if (horizon.contains('3-5')) {
      return 'Среднесрочные цели дают баланс между амбициями и реализмом.';
    }
    return 'Краткосрочные цели важны, но не забывайте о долгосрочной перспективе.';
  }

  static String _getCurrentStateInsight(int state) {
    if (state >= 8) {
      return 'Вы находитесь в отличной форме! Используйте этот импульс.';
    }
    if (state >= 6) {
      return 'Хорошая база для роста. Есть потенциал для прорыва.';
    }
    if (state >= 4) {
      return 'Середина пути. Время для переосмысления подхода.';
    }
    return 'Сложный период. Но именно он закаляет характер.';
  }

  static String _getChallengeInsight(String challenge) {
    if (challenge.contains('комфорта')) {
      return 'Выход из зоны комфорта - ключ к трансформации.';
    } else if (challenge.contains('страх')) {
      return 'Преодоление страха освобождает огромную энергию.';
    }
    return 'Принятие вызова - первый шаг к изменениям.';
  }

  // Генерация рекомендаций
  static String _getValuesRecommendation(List values) {
    return 'Проверяйте каждое решение через призму своих ценностей.';
  }

  static String _getTimeHorizonRecommendation(String horizon) {
    return 'Разбейте долгосрочные цели на квартальные вехи.';
  }

  static String _getCurrentStateRecommendation(int state) {
    if (state < 6) {
      return 'Начните с малого: одно улучшение в день.';
    }
    return 'Поднимите планку: добавьте амбициозную цель.';
  }

  static String _getChallengeRecommendation(String challenge) {
    return 'Выделите 30 минут завтра на первый шаг к этому вызову.';
  }

  // Генерация сильных сторон и зон роста
  static List<String> _getValuesStrengths(List values) {
    return [
      'Четкое понимание приоритетов',
      'Осознанность в выборе направления',
    ];
  }

  static List<String> _getValuesGrowthAreas(List values) {
    return [
      'Регулярная переоценка ценностей',
      'Согласование действий с ценностями',
    ];
  }

  // Генерация итогового summary
  static String _generateSummary(
    Map<String, dynamic> answers,
    Map<String, dynamic> results,
  ) {
    final totalScore = results['totalScore'] as double;
    final readiness = results['readinessLevel'] as String;

    final buffer = StringBuffer();
    buffer.writeln('🎯 Уровень готовности: $readiness');
    buffer.writeln('📊 Общий балл: ${(totalScore * 100).toStringAsFixed(0)}%');
    buffer.writeln();

    if (answers['values'] != null) {
      final values = answers['values'] as List;
      buffer.writeln('✨ Ваши главные ценности:');
      for (var i = 0; i < values.length && i < 3; i++) {
        buffer.writeln('${i + 1}. ${values[i]}');
      }
      buffer.writeln();
    }

    if (answers['challenge'] != null) {
      buffer.writeln('🚀 Принятый вызов: ${answers['challenge']}');
      buffer.writeln();
    }

    final nextSteps = results['nextSteps'] as List<String>;
    buffer.writeln('📌 Следующие шаги:');
    for (var i = 0; i < nextSteps.length && i < 3; i++) {
      buffer.writeln('• ${nextSteps[i]}');
    }

    return buffer.toString();
  }

  // Определение эмоционального тона
  static String _detectEmotionalTone(Map<String, dynamic> answers) {
    if (answers['current_state'] != null) {
      final state = int.parse(answers['current_state'].toString());
      if (state >= 8) return 'Вдохновленный';
      if (state >= 6) return 'Оптимистичный';
      if (state >= 4) return 'Нейтральный';
      return 'Ищущий';
    }
    return 'Исследующий';
  }

  // Генерация тегов
  static List<String> _generateTags(
    Map<String, dynamic> answers,
    Map<String, dynamic> results,
  ) {
    final tags = <String>[];

    if (answers['values'] != null) {
      final values = answers['values'] as List;
      if (values.contains('Личностный рост')) tags.add('Саморазвитие');
      if (values.contains('Творческая реализация')) tags.add('Творчество');
      if (values.contains('Здоровье и энергия')) tags.add('Здоровье');
    }

    final totalScore = results['totalScore'] as double;
    if (totalScore >= 0.8) tags.add('Высокая готовность');

    return tags;
  }

  // Генерация заголовка
  static String _generateTitle(
    Map<String, dynamic> answers,
    Map<String, dynamic> results,
  ) {
    final emotionalTone = _detectEmotionalTone(answers);
    final date = DateTime.now();
    final month = _getMonthName(date.month);

    return '$emotionalTone путь - $month ${date.year}';
  }

  // Уровень готовности
  static String _getReadinessLevel(double score) {
    if (score >= 0.85) return 'Готов к прорыву';
    if (score >= 0.7) return 'Уверенный старт';
    if (score >= 0.5) return 'Формирование базы';
    return 'Начало осознания';
  }

  // Генерация следующих шагов
  static List<String> _generateNextSteps(
    Map<String, dynamic> answers,
    double totalScore,
  ) {
    final steps = <String>[];

    if (totalScore >= 0.7) {
      steps.add('Поставьте одну амбициозную цель на этот квартал');
      steps.add('Найдите наставника или сообщество единомышленников');
      steps.add('Запустите проект, который откладывали');
    } else {
      steps.add('Уделите 15 минут ежедневной рефлексии');
      steps.add('Определите одну привычку для изменения');
      steps.add('Изучите новый навык, который вас вдохновляет');
    }

    return steps;
  }

  // Вспомогательный метод для названия месяца
  static String _getMonthName(int month) {
    const months = [
      '',
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return months[month];
  }
}
