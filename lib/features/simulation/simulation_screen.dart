// lib/features/simulation/simulation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/simulation_state.dart';
import '../../models/simulation_result.dart';
import '../../models/simulation_scenario.dart';
import '../../core/constants/app_colors.dart';
import '../../ui/components/glass_card.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  int selectedScenarioIndex = 0;
  bool _isRunning = false;

  double _workloadModifier = 0.0;
  double _interestModifier = 0.0;
  double _stressModifier = 0.0;

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final PageController _pageController = PageController();
  bool _showCustomization = false;

  @override
  void initState() {
    super.initState();
    final scenarios = ref.read(scenariosProvider);
    if (scenarios.isNotEmpty) {
      _titleController.text = scenarios.first.title;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _runSimulation() async {
    setState(() {
      _isRunning = true;
    });

    final scenarios = ref.read(scenariosProvider);
    final selectedScenario = scenarios[selectedScenarioIndex];

    // Плавная прокрутка к результатам
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );

    await Future.delayed(const Duration(seconds: 2));

    ref
        .read(simulationsProvider.notifier)
        .addCustomSimulation(
          scenarioId: selectedScenario.id,
          title: _titleController.text.isNotEmpty
              ? _titleController.text
              : selectedScenario.title,
          customNote: _noteController.text.isNotEmpty
              ? _noteController.text
              : null,
          workloadModifier: _workloadModifier,
          interestModifier: _interestModifier,
          stressModifier: _stressModifier,
        );

    setState(() {
      _isRunning = false;
      _showCustomization = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      _showSuccessDialog(context, selectedScenario.title);
    }
  }

  void _showSuccessDialog(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightest,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight, width: 2),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Simulation Complete!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "'$title' has been saved to your analytics",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: Text(
                          'Run Another',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToAnalyticsWithFilter(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'View Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAnalyticsWithFilter(BuildContext context) {
    final scenarios = ref.read(scenariosProvider);
    final selectedCategory = scenarios[selectedScenarioIndex].category;

    Navigator.pushNamed(
      context,
      '/analytics',
      arguments: {'initialCategory': selectedCategory},
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = ref.watch(scenariosProvider);
    final stats = ref.watch(simulationStatsProvider);
    final latestSimulation = ref.watch(latestSimulationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Фоновый градиент
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.secondaryGradient),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Заголовок с анимированным индикатором
                _buildHeader(stats.total),

                // Индикатор прогресса
                if (_isRunning) _buildProgressIndicator(),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Первая страница: выбор сценария и настройка
                      _buildContent(scenarios, stats, latestSimulation),

                      // Вторая страница: результаты (во время симуляции)
                      _buildResultsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int simulationCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life Simulation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      '$simulationCount simulations • Explore possibilities',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/analytics');
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Статистика в виде круговых индикаторов
          _buildMiniStats(ref.watch(simulationStatsProvider)),
        ],
      ),
    );
  }

  Widget _buildMiniStats(SimulationStats stats) {
    return Row(
      children: [
        _buildCircularStat('Total', '${stats.total}', AppColors.primary),
        const SizedBox(width: 16),
        _buildCircularStat(
          'Categories',
          '${stats.categories}',
          AppColors.success,
        ),
        const SizedBox(width: 16),
        _buildCircularStat(
          'Avg Score',
          '${(stats.avgInterest * 100).toInt()}%',
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildCircularStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(76), width: 1.5),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: LinearProgressIndicator(
        backgroundColor: AppColors.borderLight,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        borderRadius: BorderRadius.circular(4),
        minHeight: 3,
      ),
    );
  }

  Widget _buildContent(
    List<SimulationScenario> scenarios,
    SimulationStats stats,
    SimulationResult? latestSimulation,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),

        // Карточка подсказки
        _buildTipCard(),
        const SizedBox(height: 24),

        // Выбор сценария с горизонтальным скроллом
        _buildScenarioCarousel(scenarios),
        const SizedBox(height: 24),

        // Панель кастомизации
        if (_showCustomization && scenarios.isNotEmpty)
          _buildCustomizationPanel(scenarios[selectedScenarioIndex])
        else
          _buildQuickActions(),

        const SizedBox(height: 24),

        // Кнопка запуска
        _buildRunButton(
          scenarios.isNotEmpty ? scenarios[selectedScenarioIndex] : null,
        ),
        const SizedBox(height: 24),

        // Последняя симуляция
        if (latestSimulation != null)
          _buildLatestSimulationCard(latestSimulation),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTipCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLightest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pro Tip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Adjust sliders to match your personal preferences',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  setState(() => _showCustomization = !_showCustomization),
              icon: Icon(
                _showCustomization
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCarousel(List<SimulationScenario> scenarios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Path',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a scenario to explore',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: scenarios.length,
            itemBuilder: (context, index) {
              final scenario = scenarios[index];
              final isSelected = selectedScenarioIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedScenarioIndex = index;
                    _titleController.text = scenario.title;
                  });
                },
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(
                    right: index == scenarios.length - 1 ? 0 : 12,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: Column(
                    children: [
                      // Верхняя часть с иконкой
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scenario.colorValue.withAlpha(38)
                                : AppColors.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: scenario.colorValue.withAlpha(76),
                                    width: 2,
                                  )
                                : Border.all(
                                    color: AppColors.borderLight,
                                    width: 1,
                                  ),
                          ),
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    scenario.colorValue.withAlpha(230),
                                    scenario.colorValue.withAlpha(179),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: scenario.colorValue.withAlpha(
                                            76,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                scenario.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Нижняя часть с текстом
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? scenario.colorValue.withAlpha(20)
                              : AppColors.surfaceElevated,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border.all(
                            color: isSelected
                                ? scenario.colorValue.withAlpha(51)
                                : AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scenario.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              scenario.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: scenario.colorValue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                icon: Icons.tune_rounded,
                label: 'Customize',
                color: AppColors.primary,
                onTap: () => setState(() => _showCustomization = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.history_rounded,
                label: 'History',
                color: AppColors.info,
                onTap: () => Navigator.pushNamed(context, '/analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.help_outline_rounded,
                label: 'Help',
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, '/assistant'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationPanel(SimulationScenario scenario) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Simulation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Поле ввода названия
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Simulation Title',
            hintText: 'Give this simulation a name...',
            prefixIcon: Icon(
              Icons.title_rounded,
              color: AppColors.textTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),

        // Слайдеры с улучшенным дизайном
        _buildModernSlider(
          label: 'Workload',
          icon: Icons.work_outline_rounded,
          value: _workloadModifier,
          onChanged: (value) => setState(() => _workloadModifier = value),
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildModernSlider(
          label: 'Interest',
          icon: Icons.favorite_outline_rounded,
          value: _interestModifier,
          onChanged: (value) => setState(() => _interestModifier = value),
          color: AppColors.success,
        ),
        const SizedBox(height: 16),
        _buildModernSlider(
          label: 'Stress',
          icon: Icons.mood_bad_rounded,
          value: _stressModifier,
          onChanged: (value) => setState(() => _stressModifier = value),
          color: AppColors.error,
        ),
        const SizedBox(height: 16),

        // Поле для заметок
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Personal Notes',
            hintText: 'Add any thoughts or context...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),

        const SizedBox(height: 20),

        // Предпросмотр метрик в виде дашборда
        _buildMetricsDashboard(scenario),
      ],
    );
  }

  Widget _buildModernSlider({
    required String label,
    required IconData icon,
    required double value,
    required Function(double) onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value > 0 ? '+' : ''}${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: color,
            inactiveTrackColor: color.withAlpha(51),
            thumbColor: Colors.white,
            overlayColor: color.withAlpha(51),
          ),
          child: Slider(
            value: value,
            min: -0.5,
            max: 0.5,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsDashboard(SimulationScenario scenario) {
    final adjustedWorkload =
        (scenario.baseMetrics['workload']! + _workloadModifier).clamp(0.0, 1.0);
    final adjustedInterest =
        (scenario.baseMetrics['interest']! + _interestModifier).clamp(0.0, 1.0);
    final adjustedStress = (scenario.baseMetrics['stress']! + _stressModifier)
        .clamp(0.0, 1.0);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Metrics Preview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildMetricGauge(
                  'Workload',
                  scenario.baseMetrics['workload']!,
                  adjustedWorkload,
                  AppColors.primary,
                ),
                const SizedBox(width: 16),
                _buildMetricGauge(
                  'Interest',
                  scenario.baseMetrics['interest']!,
                  adjustedInterest,
                  AppColors.success,
                ),
                const SizedBox(width: 16),
                _buildMetricGauge(
                  'Stress',
                  scenario.baseMetrics['stress']!,
                  adjustedStress,
                  AppColors.error,
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // Прогноз результата
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predicted Outcome',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getPredictionText(
                          adjustedInterest,
                          adjustedStress,
                          adjustedWorkload,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGauge(
    String label,
    double base,
    double adjusted,
    Color color,
  ) {
    final hasChanged = (base - adjusted).abs() > 0.01;

    return Expanded(
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: adjusted,
                  backgroundColor: color.withAlpha(25),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 4,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${(adjusted * 100).toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasChanged)
            Text(
              '${base > adjusted ? '↓' : '↑'} ${((adjusted - base).abs() * 100).toInt()}%',
              style: TextStyle(
                fontSize: 9,
                color: base > adjusted ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  String _getPredictionText(double interest, double stress, double workload) {
    final score = interest * 0.4 + (1 - stress) * 0.3 + (1 - workload) * 0.2;

    if (score > 0.75) return 'Excellent match with high fulfillment potential';
    if (score > 0.6) return 'Good balance with room for optimization';
    if (score > 0.45) return 'Moderate fit, consider adjustments';
    return 'Challenging path, explore alternatives';
  }

  Widget _buildRunButton(SimulationScenario? scenario) {
    if (scenario == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(76),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isRunning ? null : _runSimulation,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRunning)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  _isRunning ? 'Running Simulation...' : 'Launch Simulation',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestSimulationCard(SimulationResult simulation) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(230),
                        AppColors.primaryLight.withAlpha(179),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Simulation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _timeAgo(simulation.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(
                      (simulation.metrics['overallScore'] ?? 0),
                    ).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getScoreColor(
                        (simulation.metrics['overallScore'] ?? 0),
                      ).withAlpha(76),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${((simulation.metrics['overallScore'] ?? 0) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getScoreColor(
                        (simulation.metrics['overallScore'] ?? 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              simulation.scenarioTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Мини-метрики в ряд
            Row(
              children: [
                _buildMiniMetricChip(
                  'Interest',
                  simulation.metrics['interest'] ?? 0,
                  AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildMiniMetricChip(
                  'Workload',
                  simulation.metrics['workload'] ?? 0,
                  AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildMiniMetricChip(
                  'Stress',
                  simulation.metrics['stress'] ?? 0,
                  AppColors.error,
                ),
              ],
            ),

            if (simulation.customNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        simulation.customNote!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetricChip(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(76),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Analyzing Scenario...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your simulation is being processed',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score > 0.7) return AppColors.success;
    if (score > 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 30) return '${difference.inDays}d ago';
    return '${(difference.inDays / 30).floor()}mo ago';
  }
}
