// lib/features/journey/screens/life_simulation_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yauctor_ai/features/journey/journey_screen.dart';
import 'package:yauctor_ai/features/journey/screens/journeys_overview_screen.dart';
import '../models/life_simulation.dart';
import '../providers/life_simulation_provider.dart';

class LifeSimulationScreen extends ConsumerStatefulWidget {
  const LifeSimulationScreen({super.key});

  @override
  ConsumerState<LifeSimulationScreen> createState() =>
      _LifeSimulationScreenState();
}

class _LifeSimulationScreenState extends ConsumerState<LifeSimulationScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();
  bool _isCompleting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex <
        ref.read(simulationQuestionsProvider).length - 1) {
      setState(() => _currentQuestionIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSimulation();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSimulation() async {
    setState(() => _isCompleting = true);

    try {
      final answers = ref.read(simulationStateProvider);
      final simulation = await ref
          .read(lifeSimulationsProvider.notifier)
          .createSimulation(answers);

      if (simulation != null && mounted) {
        // Очищаем состояние
        ref.read(simulationStateProvider.notifier).state = {};

        // Возвращаем созданную симуляцию
        Navigator.of(context).pop(simulation);
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(simulationQuestionsProvider);
    final progress = ref.watch(simulationProgressProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Симуляция жизни',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          // Фоновый градиент
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Хедер с прогрессом
                _buildHeader(progress, questions.length),

                // Вопросы
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    onPageChanged: (index) {
                      setState(() => _currentQuestionIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildQuestionPage(questions[index]);
                    },
                  ),
                ),

                // Навигация
                _buildNavigation(),
              ],
            ),
          ),

          // Индикатор загрузки
          if (_isCompleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double progress, int totalQuestions) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
              ),
              const Spacer(),
              Text(
                '${_currentQuestionIndex + 1}/$totalQuestions',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(SimulationQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          if (question.hint != null) ...[
            const SizedBox(height: 12),
            Text(
              question.hint!,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 32),
          _buildAnswerInput(question),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(SimulationQuestion question) {
    final currentAnswer = ref.watch(
      simulationStateProvider.select((state) => state[question.id]),
    );

    switch (question.type) {
      case SimulationQuestionType.multipleChoice:
        return _buildMultipleChoice(question, currentAnswer);
      case SimulationQuestionType.scale:
        return _buildScale(question, currentAnswer);
      case SimulationQuestionType.priorityRank:
        return _buildPriorityRank(question, currentAnswer);
      case SimulationQuestionType.openText:
        return _buildOpenText(question, currentAnswer);
    }
  }

  Widget _buildMultipleChoice(
    SimulationQuestion question,
    dynamic currentAnswer,
  ) {
    return Column(
      children: question.options.map((option) {
        final isSelected = currentAnswer == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              ref.read(simulationStateProvider.notifier).update((state) {
                return {...state, question.id: option};
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF818CF8)
                            : const Color(0xFFE2E8F0),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScale(SimulationQuestion question, dynamic currentAnswer) {
    final value = currentAnswer != null
        ? int.parse(currentAnswer.toString())
        : 5;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1',
              style: TextStyle(
                color: value == 1
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '10',
              style: TextStyle(
                color: value == 10
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF6366F1),
            inactiveTrackColor: const Color(0xFF1E293B),
            thumbColor: const Color(0xFF6366F1),
            overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (newValue) {
              ref.read(simulationStateProvider.notifier).update((state) {
                return {...state, question.id: newValue.toInt().toString()};
              });
            },
          ),
        ),
        Text(
          'Текущее значение: $value',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityRank(
    SimulationQuestion question,
    dynamic currentAnswer,
  ) {
    final List<String> selectedOptions = currentAnswer is List
        ? List<String>.from(currentAnswer)
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedOptions.isNotEmpty) ...[
          const Text(
            'Выбранные приоритеты:',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...selectedOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final updated = List<String>.from(selectedOptions)
                        ..removeAt(index);
                      ref.read(simulationStateProvider.notifier).update((
                        state,
                      ) {
                        return {...state, question.id: updated};
                      });
                    },
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        const Text(
          'Доступные варианты:',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...question.options.where((opt) => !selectedOptions.contains(opt)).map((
          option,
        ) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                if (selectedOptions.length < 3) {
                  final updated = [...selectedOptions, option];
                  ref.read(simulationStateProvider.notifier).update((state) {
                    return {...state, question.id: updated};
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOpenText(SimulationQuestion question, dynamic currentAnswer) {
    return TextField(
      onChanged: (value) {
        ref.read(simulationStateProvider.notifier).update((state) {
          return {...state, question.id: value};
        });
      },
      maxLines: 5,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Поделитесь своими мыслями...',
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildNavigation() {
    final questions = ref.watch(simulationQuestionsProvider);
    final currentAnswer = ref.watch(
      simulationStateProvider.select(
        (state) => state[questions[_currentQuestionIndex].id],
      ),
    );

    final canProceed =
        currentAnswer != null &&
        (currentAnswer is! String || currentAnswer.isNotEmpty) &&
        (currentAnswer is! List || currentAnswer.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF334155)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Назад',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                disabledBackgroundColor: const Color(0xFF334155),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentQuestionIndex == questions.length - 1
                    ? 'Завершить'
                    : 'Далее',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Экран результатов симуляции
class SimulationResultScreen extends StatelessWidget {
  final LifeSimulation simulation;

  const SimulationResultScreen({super.key, required this.simulation});

  @override
  Widget build(BuildContext context) {
    final results = simulation.results;
    final totalScore = results['totalScore'] as double;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        title: const Text(
          'Результаты симуляции',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Общий балл
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.2),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${(totalScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        results['readinessLevel'] as String,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Summary
                Text(
                  simulation.summary,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // Кнопка перехода к Journey
                ElevatedButton(
                  onPressed: () {
                    // ВАЖНО: Используйте pushAndRemoveUntil для очистки стека
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const JourneysOverviewScreen(),
                      ),
                      (route) => false, // Удаляем все предыдущие экраны
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Посмотреть мой путь',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
