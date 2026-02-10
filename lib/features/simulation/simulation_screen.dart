// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  // Константы цветов из макета
  final Color _primaryColor = const Color(0xFF8B5CF6); // Фиолетовый
  final Color _secondaryColor = const Color(
    0xFFF5F3FF,
  ); // Светло-фиолетовый фон
  final Color _greenColor = const Color(0xFF4ADE80);
  final Color _blueColor = const Color(0xFF60A5FA);
  final Color _pinkColor = const Color(0xFFF472B6);
  final Color _redColor = const Color(0xFFEF4444);
  final Color _orangeColor = const Color(0xFFFBBF24);

  // Состояние экрана
  // 0: Ввод вопроса
  // 1: Сценарии сгенерированы (список)
  // 2: Результаты (детальный просмотр)
  int _currentStep = 0;
  bool _isLoading = false;

  // Ввод
  final TextEditingController _questionController = TextEditingController();

  // Выбор сценария
  int? _selectedScenarioIndex;

  // Табы результатов (0: Траектории, 1: Сравнение, 2: Динамика)
  int _resultTabIndex = 1; // По умолчанию "Сравнение" как на скриншоте 5/6

  // --- ДАННЫЕ (Mock Data на основе скриншотов) ---

  final List<String> _exampleQuestions = [
    "Что если я буду работать 20 часов в неделю?",
    "Что если я уйду в Data Science?",
    "Что если я перевестись в другой вуз?",
    "Что если я сменю город?",
  ];

  late final List<Map<String, dynamic>> _scenarios;

  @override
  void initState() {
    super.initState();
    // Инициализация данных сценариев (как на скриншоте 3)
    _scenarios = [
      {
        'title': 'Полный переход в Data Science',
        'subtitle':
            'Переобучение на Data Science через курсы, полный переход через 12-18 месяцев',
        'metrics': {
          'energy': {'val': 48, 'color': _primaryColor},
          'finance': {'val': 45, 'color': _redColor},
          'time': {'val': 35, 'color': _redColor},
          'psych': {'val': 55, 'color': _orangeColor},
          'risk': {'val': 65, 'color': _redColor},
        },
        'bullets': [
          'Зарплата ↓40% (2 года)',
          'Импостер-синдром 6 мес',
          'Риск выгорания 65%',
        ],
        'isRecommended': true, // Для фиолетовой точки
      },
      {
        'title': 'Остаться в маркетинге',
        'subtitle':
            'Сменить роль внутри маркетинга (переход в marketing analytics)',
        'metrics': {
          'energy': {'val': 72, 'color': _greenColor},
          'finance': {'val': 85, 'color': _greenColor},
          'time': {'val': 78, 'color': _greenColor},
          'psych': {'val': 75, 'color': _greenColor},
          'risk': {'val': 35, 'color': _orangeColor},
        },
        'bullets': [
          'Зарплата +25% через год',
          'Текущие навыки ценны',
          'Потолок роста меньше',
        ],
        'isRecommended': false,
      },
      {
        'title': 'Гибридный путь',
        'subtitle': 'Marketing analytics + курсы Python/SQL (5-10ч/нед)',
        'metrics': {
          'energy': {'val': 78, 'color': _greenColor},
          'finance': {'val': 92, 'color': _greenColor},
          'time': {'val': 72, 'color': _greenColor},
          'psych': {'val': 82, 'color': _greenColor},
          'risk': {'val': 22, 'color': _greenColor},
        },
        'bullets': [
          'Финансы стабильны',
          'Постепенный переход',
          'Стресс минимален',
        ],
        'isRecommended': false,
      },
    ];
  }

  // Логика перехода
  void _generateScenarios() {
    if (_questionController.text.isEmpty) {
      _questionController.text =
          "Что если я уйду в Data Science?"; // Автозаполнение для демо
    }
    setState(() => _isLoading = true);
    // Имитация загрузки
    Timer(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() {
        _isLoading = false;
        _currentStep = 1; // Переход к списку сценариев
      });
    });
  }

  void _showResults() {
    if (_selectedScenarioIndex == null) return;
    setState(() => _isLoading = true);
    Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
        _currentStep = 2; // Переход к экрану результатов
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Обработка кнопки "Назад" в AppBar
    void handleBack() {
      if (_currentStep == 2) {
        setState(() => _currentStep = 1);
      } else if (_currentStep == 1) {
        setState(() {
          _currentStep = 0;
          _selectedScenarioIndex = null;
        });
      } else {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: handleBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == 2
                  ? "Результаты симуляции"
                  : "Симуляция сценариев",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (_currentStep == 2)
              const Text(
                "Сравнение траекторий",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            else
              const Text(
                "Исследуйте альтернативные пути",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _primaryColor))
            : _buildBody(),
      ),
      // Плавающая кнопка действия только на шаге выбора (шаг 1), если выбрана карточка
      bottomNavigationBar: _currentStep == 1 && _selectedScenarioIndex != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _showResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Сравнить траектории",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return _buildInputStep();
      case 1:
        return _buildSelectionStep();
      case 2:
        return _buildResultsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- ШАГ 1: ВВОД ВОПРОСА ---
  Widget _buildInputStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Как это работает" (Картинка 1)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: _primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Как это работает",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Задайте вопрос "Что если...", и ваш цифровой двойник смоделирует возможные сценарии с реалистичными метриками и траекториями.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Поле ввода
          const Text(
            "Ваш вопрос",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _questionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Что если я...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Кнопка генерации
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateScenarios,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text(
                "Сгенерировать сценарии",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .grey[300], // Изначально серый, или primary если есть текст
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith((
                      states,
                    ) {
                      return _primaryColor; // Упростим: всегда активна для демо
                    }),
                  ),
            ),
          ),
          const SizedBox(height: 32),

          // Примеры вопросов
          const Text(
            "Примеры вопросов",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exampleQuestions.length,
            separatorBuilder: (c, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _questionController.text = _exampleQuestions[index];
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Text(
                    _exampleQuestions[index],
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- ШАГ 2: ВЫБОР СЦЕНАРИЯ (Картинки 3 и 4) ---
  Widget _buildSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Как это работает" (свернутое или то же самое)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: _primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Как это работает",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Задайте вопрос "Что если...", и ваш цифровой двойник...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Вопрос пользователя (read only)
          const Text(
            "Ваш вопрос",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              _questionController.text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Выберите сценарии (до 3)",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: Text(
                  "Изменить вопрос",
                  style: TextStyle(color: _primaryColor),
                ),
              ),
            ],
          ),

          // Список карточек
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _scenarios.length,
            itemBuilder: (context, index) {
              final scenario = _scenarios[index];
              final isSelected = _selectedScenarioIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedScenarioIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок и радио-кнопка
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              scenario['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? _primaryColor
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              color: isSelected
                                  ? _primaryColor
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scenario['subtitle'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),

                      // Метрики (Иконки + Проценты)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetricItem(
                            Icons.bolt,
                            "Энергия",
                            scenario['metrics']['energy']['val'],
                            scenario['metrics']['energy']['color'],
                          ),
                          _buildMetricItem(
                            Icons.attach_money,
                            "Финансы",
                            scenario['metrics']['finance']['val'],
                            scenario['metrics']['finance']['color'],
                          ),
                          _buildMetricItem(
                            Icons.schedule,
                            "Время",
                            scenario['metrics']['time']['val'],
                            scenario['metrics']['time']['color'],
                          ),
                          _buildMetricItem(
                            Icons.favorite_border,
                            "Псих.",
                            scenario['metrics']['psych']['val'],
                            scenario['metrics']['psych']['color'],
                          ),
                          _buildMetricItem(
                            Icons.warning_amber,
                            "Риск",
                            scenario['metrics']['risk']['val'],
                            scenario['metrics']['risk']['color'],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Буллиты
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (scenario['bullets'] as List).map<Widget>((
                          bullet,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  bullet,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80), // Место под FAB
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          "$value%",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // --- ШАГ 3: РЕЗУЛЬТАТЫ (Картинки 5, 6, 7) ---
  Widget _buildResultsStep() {
    final scenario = _scenarios[_selectedScenarioIndex!];

    return Column(
      children: [
        // Верхняя часть: Вопрос
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _secondaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: _primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ваш вопрос",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _questionController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Таб-переключатель
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTabBtn("Траектории", 0),
                _buildTabBtn("Сравнение", 1),
                _buildTabBtn("Динамика", 2),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Контент табов
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название выбранного сценария (Только для Динамики и Сравнения, в Траекториях может быть иначе, но оставим общим)
                if (_resultTabIndex != 0) ...[
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scenario['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_resultTabIndex ==
                          1) // Стрелочка сворачивания для стиля
                        Icon(Icons.keyboard_arrow_up, color: Colors.grey[400]),
                    ],
                  ),
                  if (_resultTabIndex == 1) // Подзаголовок только в сравнении
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Text(
                        scenario['subtitle'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ),
                ],

                // Переключение контента
                if (_resultTabIndex == 0) _buildTrajectoryTabContent(),
                if (_resultTabIndex == 1) _buildComparisonTabContent(scenario),
                if (_resultTabIndex == 2) _buildDynamicsTabContent(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Нижние кнопки (Новый вопрос / Обсудить)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                      _questionController.clear();
                      _selectedScenarioIndex = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Новый вопрос",
                    style: TextStyle(color: _primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Обсудить с AI",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBtn(String title, int index) {
    bool isSelected = _resultTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _resultTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 1: ТРАЕКТОРИИ (Графики) ---
  Widget _buildTrajectoryTabContent() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildChartCard(
          "Траектория энергии",
          Icons.bolt_outlined,
          _primaryColor,
          [50, 48, 46, 44, 42, 41, 40],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          "Психологическое состояние",
          Icons.favorite_border,
          _primaryColor.withOpacity(0.7),
          [55, 54, 53, 52, 51, 50, 49],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          "Финансовая динамика",
          Icons.attach_money,
          _primaryColor.withOpacity(0.5),
          [45, 45, 46, 46, 47, 47, 48],
        ),

        const SizedBox(height: 24),
        // Легенда снизу как на картинке
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _scenarios[_selectedScenarioIndex!]['title'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(
    String title,
    IconData icon,
    Color color,
    List<double> dataPoints,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: SimpleLineChartPainter(data: dataPoints, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: СРАВНЕНИЕ (Прогресс бары) ---
  Widget _buildComparisonTabContent(Map<String, dynamic> scenario) {
    final m = scenario['metrics'];
    return Column(
      children: [
        _buildProgressBar("Энергия", m['energy']['val'], m['energy']['color']),
        _buildProgressBar(
          "Финансы",
          m['finance']['val'],
          m['finance']['color'],
        ),
        _buildProgressBar(
          "Время",
          m['time']['val'],
          _blueColor,
        ), // На скрине синий
        _buildProgressBar("Психология", m['psych']['val'], _pinkColor),
        _buildProgressBar("Риск выгорания", m['risk']['val'], _redColor),

        const SizedBox(height: 24),

        // Ключевые моменты (если есть в мапе, но мы возьмем из bullets)
        /*Container(
           padding: EdgeInsets.all(16),
           decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text("Ключевые моменты", style: TextStyle(color: Colors.grey)),
               SizedBox(height: 8),
               ...(scenario['bullets'] as List).map((b) => Padding(
                 padding: EdgeInsets.only(bottom: 4),
                 child: Row(children: [Icon(Icons.trip_origin, size:12, color: _primaryColor), SizedBox(width:8), Text(b)]),
               )).toList()
             ],
           ),
        ),
        SizedBox(height: 16),*/

        // AI Анализ
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _secondaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: _primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    "AI-анализ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "На основе вашего цифрового двойника, рекомендуем взвесить краткосрочные выгоды против долгосрочного благополучия. Оптимальный путь часто находится между крайностями.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _getIconForLabel(label, color),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 14)),
                ],
              ),
              Text(
                "$value%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[100],
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getIconForLabel(String label, Color color) {
    IconData icon;
    switch (label) {
      case "Энергия":
        icon = Icons.bolt;
        break;
      case "Финансы":
        icon = Icons.attach_money;
        break;
      case "Время":
        icon = Icons.schedule;
        break;
      case "Психология":
        icon = Icons.favorite_border;
        break;
      case "Риск выгорания":
        icon = Icons.error_outline;
        break;
      default:
        icon = Icons.circle;
    }
    return Icon(icon, size: 18, color: color);
  }

  // --- TAB 3: ДИНАМИКА ---
  Widget _buildDynamicsTabContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildDynamicCard("Адаптация", "Месяц 1-2", 38, 55, 50, [
          'Начало работы в кафе',
          'Первые смены (16-20ч)',
          'Корректировка расписания учёбы',
        ]),
        const SizedBox(height: 12),
        _buildDynamicCard("Формирование ритма", "Месяц 3-4", 43, 45, 65, [
          'Привыкание к нагрузке',
          'Первая зарплата',
          'Усталость накапливается',
        ]),
        const SizedBox(height: 12),
        _buildDynamicCard("Устойчивое состояние", "Месяц 5-6", 48, 65, 55, [
          'Рутина установилась',
          'Финансовая стабильность',
          'Мало времени на хобби',
        ]),
      ],
    );
  }

  Widget _buildDynamicCard(
    String title,
    String subtitle,
    int en,
    int stress,
    int sat,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat("Энергия", "$en%"),
              const SizedBox(width: 8),
              _buildMiniStat("Стресс", "$stress%"),
              const SizedBox(width: 8),
              _buildMiniStat("Удовл.", "$sat%"),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: _primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    it,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// Простой рисовальщик графиков (чтобы не тянуть тяжелые библиотеки)
class SimpleLineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SimpleLineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Grid lines (dotted)
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    // Draw Y axis lines
    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    // Draw X axis labels (simplified ticks)
    double stepX = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - 5),
        gridPaint,
      );
    }

    // Draw chart line
    double maxVal = 100;
    double minVal = 0;

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y =
          size.height - ((data[i] - minVal) / (maxVal - minVal) * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Draw dots
    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y =
          size.height - ((data[i] - minVal) / (maxVal - minVal) * size.height);

      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }

    // X Labels text drawing omitted for simplicity in CustomPainter,
    // usually done with TextPainter but requires layout handling.
    // Hardcoded labels (Start, 1 mon...) in UI outside this painter would be better,
    // but for the visual "look" the grid + line is sufficient.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
