// lib/features/journey/widgets/journey_widgets.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:yauctor_ai/features/journey/screens/life_simulation_screen.dart';
import 'package:yauctor_ai/ui/layout/main_layout.dart';
import 'journey_models.dart';

// Экран загрузки
Widget buildLoadingScreen(AnimationController loadingController) {
  loadingController.repeat();
  return Scaffold(
    backgroundColor: const Color(0xFF0B0F19),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(loadingController),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6366F1), width: 3),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Загружаем ваш путь...',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

// Экран ошибки
Widget buildErrorScreen(
  BuildContext context,
  String errorMessage,
  VoidCallback onRetry,
) {
  return Scaffold(
    backgroundColor: const Color(0xFF0B0F19),
    appBar: AppBar(
      backgroundColor: const Color(0xFF0B0F19),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Мой путь', style: TextStyle(color: Colors.white)),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 60),
            const SizedBox(height: 20),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              style: const TextStyle(color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Попробовать снова',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainLayout()),
                  (route) => false,
                );
              },
              child: const Text(
                'Вернуться на главную',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Фоновую сетку
Widget buildBackgroundGrid() {
  return CustomPaint(size: const Size(6000, 6000), painter: GridPainter());
}

// Подсказка управления
Widget buildControlsHint() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1E293B).withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.touch_app, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          'Двигайте экран • Кнопки + создают ветки • Долгое нажатие - удаление',
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// Пустой начальный узел
Widget buildEmptyStartNode() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F19),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF6366F1), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.auto_awesome, size: 32, color: Color(0xFF6366F1)),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Text(
          'Начните свой путь',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

// Карточка вехи
class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback? onDelete;

  const MilestoneCard({super.key, required this.milestone, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF334155).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    milestone.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ScoreIndicator(score: milestone.score),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              milestone.description,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  milestone.date,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LifeSimulationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Открыть',
                          style: TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: Color(0xFF818CF8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Кнопка создания ветки
class NewBranchButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final String tooltip;

  const NewBranchButton({
    super.key,
    required this.onPressed,
    this.size = 60,
    this.tooltip = 'Создать ветку',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F19),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: size * 0.5,
              color: const Color(0xFF6366F1),
            ),
          ),
        ),
      ),
    );
  }
}

// Индикатор оценки
class ScoreIndicator extends StatelessWidget {
  final double score;

  const ScoreIndicator({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Color(0xFF6366F1)),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Color(0xFF818CF8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Светящийся узел
class GlowingNode extends StatelessWidget {
  final bool isActive;
  final IconData icon;

  const GlowingNode({super.key, required this.isActive, required this.icon});

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
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Center(
        child: isActive
            ? PulsingIcon(icon: icon)
            : Icon(icon, size: 18, color: const Color(0xFF475569)),
      ),
    );
  }
}

// Иконка с пульсацией
class PulsingIcon extends StatefulWidget {
  final IconData icon;

  const PulsingIcon({super.key, required this.icon});

  @override
  State<PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon>
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
          color: const Color(0xFF6366F1).withOpacity(_animation.value),
        );
      },
    );
  }
}

// Рисовальщики линий

class ConnectorLinePainter extends CustomPainter {
  final BranchDirection direction;

  ConnectorLinePainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (direction == BranchDirection.left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(-size.width, size.height / 2);
      path.lineTo(-size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VerticalBranchLinePainter extends CustomPainter {
  final bool isActive;

  VerticalBranchLinePainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? const Color(0xFF6366F1) : const Color(0xFF334155)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (isActive) {
      paint.strokeWidth = 3;
    }

    final path = Path()
      ..moveTo(22, 0)
      ..lineTo(22, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HorizontalBranchLinePainter extends CustomPainter {
  final bool isActive;

  HorizontalBranchLinePainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? const Color(0xFF818CF8) : const Color(0xFF475569)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (isActive) {
      paint.strokeWidth = 2;
    }

    final path = Path()
      ..moveTo(0, 22)
      ..lineTo(size.width, 22);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 100.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
