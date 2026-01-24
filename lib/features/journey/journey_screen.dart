// lib/features/journey/screens/journey_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yauctor_ai/features/journey/models/life_simulation.dart';
import 'package:yauctor_ai/features/journey/providers/life_simulation_provider.dart';
import 'package:yauctor_ai/features/journey/screens/life_simulation_screen.dart';
import 'package:yauctor_ai/ui/layout/main_layout.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationsAsync = ref.watch(lifeSimulationsProvider);

    // Проверяем, можем ли вернуться назад
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  // Если нельзя вернуться назад, идем на главную
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          const MainLayout(), // или ваш главный экран
                    ),
                    (route) => false,
                  );
                },
              ),
        title: const Text(
          'Мой путь',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.refresh(lifeSimulationsProvider),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: simulationsAsync.when(
        data: (simulations) => _buildContent(context, simulations),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.refresh(lifeSimulationsProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LifeSimulationScreen()),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'Новая симуляция',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<LifeSimulation> simulations) {
    // Конвертируем симуляции в вехи
    final milestones = _convertSimulationsToMilestones(simulations);

    return Stack(
      children: [
        // Фоновый атмосферный градиент
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: .2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Кинематографичный заголовок
            SliverAppBar.large(
              backgroundColor: const Color(0xFF0B0F19),
              expandedHeight: 160,
              pinned: true,
              stretch: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                expandedTitleScale: 1.2,
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF94A3B8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    'Ваша История',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.3),
                            const Color(0xFF0B0F19),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 24,
                      child: Text(
                        _getJourneySubtitle(simulations),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: const Color(0xFF6366F1).withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Список событий или пустое состояние
            if (milestones.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(context))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _CinematicTimelineItem(
                      data: milestones[index],
                      isFirst: index == 0,
                    );
                  }, childCount: milestones.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ],
    );
  }

  String _getJourneySubtitle(List<LifeSimulation> simulations) {
    if (simulations.isEmpty) {
      return 'НАЧНИТЕ СВОЙ ПУТЬ';
    }

    final daysSinceFirst = DateTime.now()
        .difference(simulations.last.createdAt)
        .inDays;

    return 'ПУТЬ ДЛИНОЮ В $daysSinceFirst ${_getDaysWord(daysSinceFirst)}';
  }

  String _getDaysWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'ДЕНЬ';
    if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'ДНЯ';
    }
    return 'ДНЕЙ';
  }

  List<_MilestoneData> _convertSimulationsToMilestones(
    List<LifeSimulation> simulations,
  ) {
    return simulations.asMap().entries.map((entry) {
      final index = entry.key;
      final sim = entry.value;
      final results = sim.results;

      return _MilestoneData(
        date: _formatDate(sim.createdAt),
        title: sim.title,
        description: _extractShortDescription(sim),
        icon: _getIconForSimulation(sim),
        isActive: index == 0,
        isLast: index == simulations.length - 1,
        score: results['totalScore'] as double,
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'СЕГОДНЯ';
    if (diff.inDays == 1) return 'ВЧЕРА';
    if (diff.inDays < 7) {
      return '${diff.inDays} ${_getDaysWord(diff.inDays)} НАЗАД';
    }

    const months = [
      '',
      'ЯНВ',
      'ФЕВ',
      'МАР',
      'АПР',
      'МАЙ',
      'ИЮН',
      'ИЮЛ',
      'АВГ',
      'СЕН',
      'ОКТ',
      'НОЯ',
      'ДЕК',
    ];
    return '${months[date.month]} ${date.year}';
  }

  String _extractShortDescription(LifeSimulation sim) {
    final results = sim.results;
    final readiness = results['readinessLevel'] as String;
    final score = results['totalScore'] as double;
    final scorePercent = (score * 100).toStringAsFixed(0);

    return '$readiness. Общий балл: $scorePercent%';
  }

  IconData _getIconForSimulation(LifeSimulation sim) {
    final score = sim.results['totalScore'] as double;

    if (score >= 0.85) return Icons.auto_awesome;
    if (score >= 0.7) return Icons.bolt_rounded;
    if (score >= 0.5) return Icons.graphic_eq;
    return Icons.flag_rounded;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 64,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Начните свой путь',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Пройдите симуляцию жизни, чтобы\nувидеть свою историю развития',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LifeSimulationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Начать симуляцию',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Модель данных
class _MilestoneData {
  final String date;
  final String title;
  final String description;
  final IconData icon;
  final bool isActive;
  final bool isLast;
  final double score;

  _MilestoneData({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
    this.isActive = false,
    this.isLast = false,
    this.score = 0.0,
  });
}

class _CinematicTimelineItem extends StatelessWidget {
  final _MilestoneData data;
  final bool isFirst;

  const _CinematicTimelineItem({required this.data, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Левая колонка: Дата + Линия
          SizedBox(
            width: 50,
            child: Column(
              children: [
                _GlowingNode(isActive: data.isActive, icon: data.icon),
                if (!data.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            data.isActive
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF334155),
                            data.isActive
                                ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                                : const Color(
                                    0xFF334155,
                                  ).withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: data.isActive
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Правая колонка: Контент
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.date,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: data.isActive
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: data.isActive
                          ? Colors.white
                          : const Color(0xFFE2E8F0),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (data.score > 0) ...[
                    const SizedBox(height: 12),
                    _ScoreIndicator(score: data.score),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingNode extends StatelessWidget {
  final bool isActive;
  final IconData icon;

  const _GlowingNode({required this.isActive, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F19),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? const Color(0xFF6366F1) : const Color(0xFF334155),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Center(
        child: isActive
            ? _PulsingIcon(icon: icon)
            : Icon(icon, size: 18, color: const Color(0xFF475569)),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  const _PulsingIcon({required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Icon(
          widget.icon,
          size: 18,
          color: const Color(0xFF6366F1).withValues(alpha: _animation.value),
        );
      },
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final double score;

  const _ScoreIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 14, color: const Color(0xFF6366F1)),
              const SizedBox(width: 4),
              Text(
                '${(score * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF818CF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
