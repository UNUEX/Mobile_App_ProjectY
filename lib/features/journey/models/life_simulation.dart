// lib/features/journey/models/life_simulation.dart
class LifeSimulation {
  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic> answers;
  final Map<String, dynamic> results;
  final String summary;
  final DateTime createdAt;
  final String? emotionalTone;
  final List<String>? tags;

  LifeSimulation({
    required this.id,
    required this.userId,
    required this.title,
    required this.answers,
    required this.results,
    required this.summary,
    required this.createdAt,
    this.emotionalTone,
    this.tags,
  });

  factory LifeSimulation.fromJson(Map<String, dynamic> json) {
    return LifeSimulation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      answers: Map<String, dynamic>.from(json['answers']),
      results: Map<String, dynamic>.from(json['results']),
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      emotionalTone: json['emotionalTone'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  double? get score => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'answers': answers,
      'results': results,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'emotionalTone': emotionalTone,
      'tags': tags,
    };
  }
}

class SimulationQuestion {
  final String id;
  final String question;
  final SimulationQuestionType type;
  final List<String> options;
  final String? hint;
  final bool? isRequired;

  const SimulationQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.hint,
    this.isRequired,
  });
}

enum SimulationQuestionType { multipleChoice, scale, openText, priorityRank }

class SimulationQuestions {
  static List<SimulationQuestion> getDefaultQuestions() {
    return [
      const SimulationQuestion(
        id: 'values',
        question: 'Какие ценности для вас наиболее важны?',
        type: SimulationQuestionType.priorityRank,
        options: [
          'Личностный рост',
          'Финансовая независимость',
          'Крепкие отношения',
          'Творческая реализация',
          'Здоровье и энергия',
          'Вклад в общество',
        ],
        hint: 'Выберите и расставьте по приоритету 3 главные ценности',
        isRequired: true,
      ),
      const SimulationQuestion(
        id: 'time_horizon',
        question: 'На какой период вы планируете свое развитие?',
        type: SimulationQuestionType.multipleChoice,
        options: [
          '3-6 месяцев (ближайшие шаги)',
          '1 год (конкретные цели)',
          '3-5 лет (долгосрочное видение)',
          '10+ лет (жизненная миссия)',
        ],
        isRequired: true,
      ),
      const SimulationQuestion(
        id: 'current_state',
        question: 'Как бы вы оценили текущий уровень удовлетворенности жизнью?',
        type: SimulationQuestionType.scale,
        options: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        hint: '1 - очень низкий, 10 - превосходный',
        isRequired: true,
      ),
      const SimulationQuestion(
        id: 'challenge',
        question: 'Какой вызов вы готовы принять прямо сейчас?',
        type: SimulationQuestionType.multipleChoice,
        options: [
          'Выйти из зоны комфорта',
          'Развить новый навык',
          'Улучшить здоровье',
          'Построить значимые отношения',
          'Начать проект мечты',
          'Преодолеть страх',
        ],
        isRequired: true,
      ),
      const SimulationQuestion(
        id: 'reflection',
        question: 'Что вы хотите изменить в своей жизни в первую очередь?',
        type: SimulationQuestionType.openText,
        options: [],
        hint: 'Опишите одну конкретную область для изменений',
        isRequired: false,
      ),
    ];
  }
}
