// lib/features/dashboard/life_analytics_screen.dart
import 'package:flutter/material.dart';

class LifeAnalyticsScreen extends StatefulWidget {
  const LifeAnalyticsScreen({super.key});

  @override
  State<LifeAnalyticsScreen> createState() => _LifeAnalyticsScreenState();
}

class _LifeAnalyticsScreenState extends State<LifeAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header с кнопкой назад
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка назад и заголовок
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6C4AB6,
                                ).withValues(alpha: .1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF6C4AB6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Life Analytics',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                          Text(
                            'Track your daily metrics',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7E69AB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE8DEFF),
                    child: const Icon(Icons.person, color: Color(0xFF6C4AB6)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C4AB6).withValues(alpha: .1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Color(0xFF7E69AB)),
                    hintText: 'Search metrics...',
                    hintStyle: TextStyle(color: Color(0xFF7E69AB)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', true),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Health', false),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Biology', false),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Productivity', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Metrics grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                  children: [
                    _buildMetricCard(
                      context,
                      'Sleep Tracker',
                      'Health & Biology',
                      Icons.bedtime,
                      const Color(0xFF8B7AB8),
                      '7.5 hrs',
                      '+12%',
                      MetricType.sleep,
                    ),
                    _buildMetricCard(
                      context,
                      'Daily News',
                      'Information',
                      Icons.newspaper,
                      const Color(0xFF6C4AB6),
                      '24 items',
                      'New',
                      MetricType.news,
                    ),
                    _buildMetricCard(
                      context,
                      'Heart Rate',
                      'Biology',
                      Icons.favorite,
                      const Color(0xFFB08BBB),
                      '72 bpm',
                      'Normal',
                      MetricType.heartRate,
                    ),
                    _buildMetricCard(
                      context,
                      'Productivity',
                      'Daily Life',
                      Icons.trending_up,
                      const Color(0xFF9575CD),
                      '85%',
                      '+5%',
                      MetricType.productivity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF6C4AB6), Color(0xFF8B7AB8)],
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF6C4AB6,
            ).withValues(alpha: isSelected ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF7E69AB),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String name,
    String category,
    IconData icon,
    Color color,
    String value,
    String change,
    MetricType type,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MetricDetailScreen(
              name: name,
              category: category,
              icon: icon,
              color: color,
              value: value,
              change: change,
              type: type,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Center(child: Icon(icon, size: 48, color: Colors.white)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7E69AB),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              change,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
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
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Детальный экран метрики
// ────────────────────────────────────────────────

class MetricDetailScreen extends StatefulWidget {
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final String value;
  final String change;
  final MetricType type;

  const MetricDetailScreen({
    super.key,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.value,
    required this.change,
    required this.type,
  });

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  bool isTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Stack(
        children: [
          // Hero-градиент вверху
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.change,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопки навигации
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
                _buildCircleButton(
                  icon: isTracking
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  onPressed: () => setState(() => isTracking = !isTracking),
                ),
              ],
            ),
          ),

          // Основной контент
          Positioned(
            top: 320,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 16,
                                  color: widget.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.change,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: widget.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: widget.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.category,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7E69AB),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Last updated: 5 min ago',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7E69AB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getDescription(widget.type),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7E69AB),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'View detailed analysis',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.color,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Weekly Overview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weekly Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C4AB6),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildStatCard(
                              'Average',
                              _getAverageValue(widget.type),
                              Icons.analytics,
                              widget.color,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Peak',
                              _getPeakValue(widget.type),
                              Icons.trending_up,
                              widget.color.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Goal',
                              _getGoalValue(widget.type),
                              Icons.flag,
                              widget.color.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1B69),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildInsights(widget.type),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInsights(MetricType type) {
    final insights = _getInsights(type);
    return insights.map((insight) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                insight['icon'] as IconData,
                color: widget.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight['description'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7E69AB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getDescription(MetricType type) {
    switch (type) {
      case MetricType.sleep:
        return 'Your sleep quality has improved by 12% this week. Your circadian rhythm is well-aligned with optimal sleep patterns. Continue maintaining consistent sleep schedule for better cognitive performance.';
      case MetricType.news:
        return 'Stay informed with personalized news feed covering science, technology, and health. 24 new articles matched your interests today. Recent topics include breakthroughs in cellular biology and neuroscience.';
      case MetricType.heartRate:
        return 'Your resting heart rate indicates excellent cardiovascular health. Current average of 72 bpm is within optimal range. Regular monitoring helps track fitness improvements and detect anomalies early.';
      case MetricType.productivity:
        return 'Your productivity score increased by 5% this week. Peak focus hours are between 9-11 AM. Consider scheduling important tasks during this window for maximum efficiency and output quality.';
    }
  }

  String _getAverageValue(MetricType type) {
    switch (type) {
      case MetricType.sleep:
        return '7.2h';
      case MetricType.news:
        return '18';
      case MetricType.heartRate:
        return '68';
      case MetricType.productivity:
        return '82%';
    }
  }

  String _getPeakValue(MetricType type) {
    switch (type) {
      case MetricType.sleep:
        return '8.5h';
      case MetricType.news:
        return '31';
      case MetricType.heartRate:
        return '145';
      case MetricType.productivity:
        return '95%';
    }
  }

  String _getGoalValue(MetricType type) {
    switch (type) {
      case MetricType.sleep:
        return '8.0h';
      case MetricType.news:
        return '20';
      case MetricType.heartRate:
        return '70';
      case MetricType.productivity:
        return '90%';
    }
  }

  List<Map<String, dynamic>> _getInsights(MetricType type) {
    switch (type) {
      case MetricType.sleep:
        return [
          {
            'icon': Icons.wb_sunny,
            'title': 'Consistent Schedule',
            'description':
                'You\'ve maintained a regular sleep schedule for 7 days',
          },
          {
            'icon': Icons.spa,
            'title': 'Deep Sleep Quality',
            'description': 'Average deep sleep: 2.5 hours per night',
          },
          {
            'icon': Icons.lightbulb,
            'title': 'Recommendation',
            'description': 'Try reducing screen time 1 hour before bed',
          },
        ];
      case MetricType.news:
        return [
          {
            'icon': Icons.science,
            'title': 'Top Category',
            'description': 'Biology & Neuroscience - 45% of your reading',
          },
          {
            'icon': Icons.access_time,
            'title': 'Reading Time',
            'description': 'Average 25 minutes per day',
          },
          {
            'icon': Icons.bookmark,
            'title': 'Saved Articles',
            'description': '12 articles saved this week',
          },
        ];
      case MetricType.heartRate:
        return [
          {
            'icon': Icons.favorite,
            'title': 'Resting HR',
            'description': 'Excellent: 12% lower than age average',
          },
          {
            'icon': Icons.directions_run,
            'title': 'HRV Score',
            'description': 'Heart Rate Variability: 68ms (Good)',
          },
          {
            'icon': Icons.trending_down,
            'title': 'Recovery',
            'description': 'Optimal recovery detected after workouts',
          },
        ];
      case MetricType.productivity:
        return [
          {
            'icon': Icons.access_time,
            'title': 'Peak Hours',
            'description': 'Most productive: 9 AM - 11 AM',
          },
          {
            'icon': Icons.task_alt,
            'title': 'Tasks Completed',
            'description': '47 tasks finished this week',
          },
          {
            'icon': Icons.psychology,
            'title': 'Focus Sessions',
            'description': 'Average deep work: 3.5 hours daily',
          },
        ];
    }
  }
}

enum MetricType { sleep, news, heartRate, productivity }
