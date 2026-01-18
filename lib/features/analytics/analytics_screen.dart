// lib/features/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/simulation_state.dart';
import '../../models/simulation_result.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulations = ref.watch(simulationsProvider);
    final stats = ref.watch(simulationStatsProvider);
    final latestSimulation = ref.watch(latestSimulationProvider);

    final Color accentColor = const Color(0xFF8B5CF6);
    final Color lightBg = const Color(0xFFF8F7FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Красивый заголовок
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.05),
                  accentColor.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analytics',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${stats.total} simulations • Insights & patterns',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (simulations.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: lightBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${stats.categories} categories',
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: simulations.isEmpty
                ? _buildEmptyState(context, accentColor)
                : _buildContent(
                    context,
                    simulations,
                    stats,
                    latestSimulation,
                    accentColor,
                    lightBg,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color accentColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 48,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No simulations yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Run your first simulation to see insights and patterns',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/simulation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Run First Simulation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SimulationResult> simulations,
    SimulationStats stats,
    SimulationResult? latestSimulation,
    Color accentColor,
    Color lightBg,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общая статистика в сетке
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(
                'Total',
                '${stats.total}',
                Icons.layers_rounded,
                accentColor,
              ),
              _buildStatCard(
                'Categories',
                '${stats.categories}',
                Icons.category_rounded,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                'Avg Interest',
                '${(stats.avgInterest * 100).toInt()}%',
                Icons.favorite_rounded,
                const Color(0xFFEF4444),
              ),
              _buildStatCard(
                'Avg Score',
                '${((stats.avgInterest + stats.avgWorkload) * 50).toInt()}%',
                Icons.star_rounded,
                const Color(0xFFF59E0B),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Последняя симуляция (если есть)
          if (latestSimulation != null) ...[
            const Text(
              'Latest Simulation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildLatestSimulationCard(latestSimulation, accentColor, lightBg),
            const SizedBox(height: 32),
          ],

          // Список всех симуляций
          Row(
            children: [
              const Text(
                'All Simulations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${simulations.length} total',
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...simulations.reversed.map((simulation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSimulationCard(simulation, accentColor, lightBg),
            );
          }),

          const SizedBox(height: 24),

          // Кнопка для новой симуляции
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/simulation');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create New Simulation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestSimulationCard(
    SimulationResult simulation,
    Color accentColor,
    Color lightBg,
  ) {
    final score = (simulation.metrics['overallScore'] ?? 0);
    final scoreColor = _getScoreColor(score);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: scoreColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        simulation.scenarioTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_capitalize(simulation.category)} • ${_timeAgo(simulation.createdAt)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withValues(alpha: 30)),
                  ),
                  child: Text(
                    '${(score * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),

            if (simulation.customNote != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note_rounded, size: 18, color: accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        simulation.customNote!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Divider(color: Colors.grey[100], height: 1),
            const SizedBox(height: 16),

            // Мини метрики
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniMetric(
                  'Interest',
                  simulation.metrics['interest'] ?? 0,
                  const Color(0xFFEF4444),
                ),
                _buildMiniMetric(
                  'Workload',
                  simulation.metrics['workload'] ?? 0,
                  accentColor,
                ),
                _buildMiniMetric(
                  'Stress',
                  simulation.metrics['stress'] ?? 0,
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationCard(
    SimulationResult simulation,
    Color accentColor,
    Color lightBg,
  ) {
    final score = (simulation.metrics['overallScore'] ?? 0);
    final scoreColor = _getScoreColor(score);
    final categoryColor = _getCategoryColor(simulation.category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(simulation.category),
                color: categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    simulation.scenarioTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_capitalize(simulation.category)} • ${_timeAgo(simulation.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(score * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score > 0.7) return const Color(0xFF10B981);
    if (score > 0.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'career':
        return const Color(0xFF10B981);
      case 'education':
        return const Color(0xFF8B5CF6);
      case 'lifestyle':
        return const Color(0xFFF59E0B);
      case 'business':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'career':
        return Icons.work_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'lifestyle':
        return Icons.self_improvement_rounded;
      case 'business':
        return Icons.business_rounded;
      default:
        return Icons.category_rounded;
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
