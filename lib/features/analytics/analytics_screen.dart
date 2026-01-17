// lib/features/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../state/simulation_state.dart';
import '../../models/simulation_result.dart';
import '../../core/constants/app_colors.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/shimmer_effect.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const AnalyticsScreen({super.key, this.initialFilters});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String selectedPeriod = 'all';
  String? selectedCategory;
  List<String> selectedMetrics = ['interest', 'workload', 'overallScore'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      selectedCategory = widget.initialFilters?['initialCategory'] as String?;
    }
    // Симуляция загрузки
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final simulations = ref.watch(simulationsProvider);
    final filteredSimulations = _filterSimulations(simulations);
    final stats = ref.watch(simulationStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Аппбар с градиентом
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(20),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/simulation');
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(76),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Основной контент
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Статистика заголовок
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Performance Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Информационная строка
                if (simulations.isNotEmpty)
                  _buildInfoRow(stats.total, filteredSimulations.length),

                const SizedBox(height: 20),

                // Панель фильтров
                _buildFilterBar(simulations),
                const SizedBox(height: 24),

                if (_isLoading) ...[
                  _buildShimmerStats(),
                  const SizedBox(height: 24),
                  _buildShimmerChart(),
                  const SizedBox(height: 24),
                  _buildShimmerList(),
                ] else if (simulations.isNotEmpty) ...[
                  // Карточки статистики
                  _buildStatsGrid(filteredSimulations),
                  const SizedBox(height: 24),

                  // Распределение по категориям
                  _buildCategoryDistribution(stats.categoryDistribution),
                  const SizedBox(height: 24),

                  // Панель выбора метрик
                  _buildMetricsSelector(),
                  const SizedBox(height: 24),

                  // График с улучшенным дизайном
                  _buildEnhancedChart(filteredSimulations),
                  const SizedBox(height: 24),

                  // Список симуляций
                  _buildSimulationsList(filteredSimulations),
                ] else ...[
                  // Пустое состояние
                  _buildEmptyState(),
                ],

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(int total, int filtered) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLightest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLighter.withAlpha(76)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Showing $filtered of $total simulations',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    selectedCategory != null
                        ? 'Filtered by ${_capitalize(selectedCategory!)}'
                        : 'All categories included',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedCategory != null || selectedPeriod != 'all')
              TextButton(
                onPressed: () => setState(() {
                  selectedCategory = null;
                  selectedPeriod = 'all';
                }),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppColors.primary.withAlpha(25),
                ),
                child: Text(
                  'Clear filters',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<SimulationResult> simulations) {
    final categories = simulations.map((s) => s.category).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Results',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Периоды
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterPill('All Time', 'all', selectedPeriod == 'all', () {
              setState(() => selectedPeriod = 'all');
            }),
            _buildFilterPill('30 Days', '30d', selectedPeriod == '30d', () {
              setState(() => selectedPeriod = '30d');
            }),
            _buildFilterPill('7 Days', '7d', selectedPeriod == '7d', () {
              setState(() => selectedPeriod = '7d');
            }),
          ],
        ),

        const SizedBox(height: 16),

        // Категории
        if (categories.isNotEmpty) ...[
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryPill('All', null, selectedCategory == null, () {
                setState(() => selectedCategory = null);
              }),
              ...categories.map((category) {
                return _buildCategoryPill(
                  _capitalize(category),
                  category,
                  selectedCategory == category,
                  () {
                    setState(() => selectedCategory = category);
                  },
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFilterPill(
    String label,
    String value,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(
    String label,
    String? value,
    bool selected,
    VoidCallback onTap,
  ) {
    final color = value != null ? _getCategoryColor(value) : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : color.withAlpha(76),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) ...[
              Icon(
                _getCategoryIcon(value),
                size: 14,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(List<SimulationResult> simulations) {
    if (simulations.isEmpty) return const SizedBox();

    final avgInterest = simulations.isNotEmpty
        ? simulations
                  .map((s) => s.metrics['interest'] ?? 0)
                  .reduce((a, b) => a + b) /
              simulations.length
        : 0.0;

    final avgWorkload = simulations.isNotEmpty
        ? simulations
                  .map((s) => s.metrics['workload'] ?? 0)
                  .reduce((a, b) => a + b) /
              simulations.length
        : 0.0;

    final categories = simulations.map((s) => s.category).toSet().length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          label: 'Avg Interest',
          value: '${(avgInterest * 100).toInt()}%',
          icon: Icons.favorite_rounded,
          color: AppColors.success,
          trend: avgInterest > 0.6 ? '+' : '-',
        ),
        _buildStatCard(
          label: 'Avg Workload',
          value: '${(avgWorkload * 100).toInt()}%',
          icon: Icons.work_rounded,
          color: AppColors.primary,
          trend: avgWorkload < 0.6 ? '+' : '-',
        ),
        _buildStatCard(
          label: 'Total Simulations',
          value: '${simulations.length}',
          icon: Icons.analytics_rounded,
          color: AppColors.info,
          trend: null,
        ),
        _buildStatCard(
          label: 'Categories',
          value: '$categories',
          icon: Icons.category_rounded,
          color: AppColors.warning,
          trend: null,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String? trend,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: trend == '+'
                            ? AppColors.success.withAlpha(25)
                            : AppColors.error.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: trend == '+'
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(Map<String, int> distribution) {
    if (distribution.isEmpty) return const SizedBox();

    final total = distribution.values.reduce((a, b) => a + b);
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Most simulated categories',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        ...sortedEntries.map((entry) {
          final percentage = (entry.value / total * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(entry.key),
                        size: 16,
                        color: _getCategoryColor(entry.key),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _capitalize(entry.key),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / total,
                    minHeight: 6,
                    backgroundColor: _getCategoryColor(entry.key).withAlpha(25),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(entry.key),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricsSelector() {
    final allMetrics = [
      {'key': 'interest', 'label': 'Interest', 'color': AppColors.success},
      {'key': 'workload', 'label': 'Workload', 'color': AppColors.primary},
      {'key': 'stress', 'label': 'Stress', 'color': AppColors.error},
      {'key': 'overallScore', 'label': 'Overall', 'color': AppColors.warning},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose metrics to display on chart',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: allMetrics.map((metric) {
            final isSelected = selectedMetrics.contains(metric['key']);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedMetrics.remove(metric['key']);
                  } else {
                    selectedMetrics.add(metric['key'] as String);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? metric['color'] as Color
                      : (metric['color'] as Color).withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? metric['color'] as Color
                        : (metric['color'] as Color).withAlpha(76),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    if (isSelected) const SizedBox(width: 8),
                    Text(
                      metric['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : metric['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnhancedChart(List<SimulationResult> simulations) {
    if (simulations.length < 2) return const SizedBox();

    final List<LineChartBarData> lineBars = [];
    final List<Color> colors = [
      AppColors.success,
      AppColors.primary,
      AppColors.error,
      AppColors.warning,
    ];

    for (var i = 0; i < selectedMetrics.length; i++) {
      final metric = selectedMetrics[i];
      final spots = simulations.asMap().entries.map((entry) {
        final index = entry.key;
        final sim = entry.value;
        return FlSpot(index.toDouble(), sim.metrics[metric] ?? 0);
      }).toList();

      final color = i < colors.length ? colors[i] : AppColors.primary;

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          shadow: Shadow(
            color: color.withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withAlpha(51), color.withAlpha(12)],
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: index % 3 == 0 ? 4 : 3,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Performance Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Simulation metrics over time',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderLight,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (simulations.length / 4).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= simulations.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '#${value.toInt() + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 0.2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.borderLight, width: 1),
                ),
                lineBarsData: lineBars,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // Устанавливаем цвет фона через функцию
                    getTooltipColor: (LineBarSpot touchedSpot) => Colors.white,
                    tooltipBorder: BorderSide(color: AppColors.border),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.barIndex;
                        // Проверка индекса для предотвращения RangeError
                        final metric = index < selectedMetrics.length
                            ? selectedMetrics[index]
                            : '';

                        return LineTooltipItem(
                          '${_getMetricLabel(metric)}: ${(spot.y * 100).toStringAsFixed(1)}%',
                          TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors[index % colors.length],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Легенда
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: selectedMetrics.asMap().entries.map((entry) {
              final index = entry.key;
              final metric = entry.value;
              final color = index < colors.length
                  ? colors[index]
                  : AppColors.primary;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getMetricLabel(metric),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationsList(List<SimulationResult> simulations) {
    if (simulations.isEmpty) return const SizedBox();

    final recentSimulations = simulations.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Simulations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Latest simulation results',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        ...recentSimulations.map((simulation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSimulationCard(simulation),
          );
        }),
      ],
    );
  }

  Widget _buildSimulationCard(SimulationResult simulation) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(simulation.category).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(simulation.category),
                  size: 20,
                  color: _getCategoryColor(simulation.category),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            simulation.scenarioTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(
                              (simulation.metrics['overallScore'] ?? 0),
                            ).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(height: 2),
                    Text(
                      '${_capitalize(simulation.category)} • ${_timeAgo(simulation.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (simulation.customNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_rounded, size: 14, color: AppColors.primary),
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

          const SizedBox(height: 12),

          // Мини-метрики
          Row(
            children: [
              _buildMiniMetric(
                'Interest',
                simulation.metrics['interest'] ?? 0,
                AppColors.success,
              ),
              const SizedBox(width: 8),
              _buildMiniMetric(
                'Workload',
                simulation.metrics['workload'] ?? 0,
                AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildMiniMetric(
                'Stress',
                simulation.metrics['stress'] ?? 0,
                AppColors.error,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Действия
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // Действие: поделиться
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // Действие: перезапустить
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: AppColors.primary.withAlpha(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.replay_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Re-run',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLightest,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLighter, width: 2),
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 40,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No simulations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run your first simulation to see analytics here',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/simulation');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Run First Simulation',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer эффекты для загрузки
  Widget _buildShimmerStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: List.generate(4, (index) {
        return ShimmerEffect(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerChart() {
    return ShimmerEffect(
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerEffect(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Helper methods
  List<SimulationResult> _filterSimulations(List<SimulationResult> all) {
    List<SimulationResult> filtered = all;

    if (selectedPeriod != 'all') {
      final now = DateTime.now();
      final days = selectedPeriod == '7d' ? 7 : 30;
      final cutoff = now.subtract(Duration(days: days));
      filtered = filtered.where((s) => s.createdAt.isAfter(cutoff)).toList();
    }

    if (selectedCategory != null) {
      filtered = filtered.where((s) => s.category == selectedCategory).toList();
    }

    return filtered;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'work':
        return AppColors.primary;
      case 'career':
        return AppColors.success;
      case 'lifestyle':
        return const Color(0xFF8B5CF6);
      case 'business':
        return AppColors.warning;
      case 'education':
        return const Color(0xFFEC4899);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'career':
        return Icons.trending_up_rounded;
      case 'lifestyle':
        return Icons.self_improvement_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getScoreColor(double score) {
    if (score > 0.7) return AppColors.success;
    if (score > 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'interest':
        return 'Interest';
      case 'workload':
        return 'Workload';
      case 'stress':
        return 'Stress';
      case 'growth':
        return 'Growth';
      case 'income':
        return 'Income';
      case 'overallScore':
        return 'Overall';
      default:
        return metric;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
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
