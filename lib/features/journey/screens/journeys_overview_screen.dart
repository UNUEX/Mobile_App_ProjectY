// lib/features/journey/screens/journeys_overview_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journey_container.dart';
import '../providers/journey_container_provider.dart';
import '../providers/life_simulation_provider.dart';
import '../services/branch_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../journey/journey_screen.dart';

class JourneysOverviewScreen extends ConsumerStatefulWidget {
  const JourneysOverviewScreen({super.key});

  @override
  ConsumerState<JourneysOverviewScreen> createState() =>
      _JourneysOverviewScreenState();
}

class _JourneysOverviewScreenState extends ConsumerState<JourneysOverviewScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _entryController;
  AnimationController? _resetController;
  Animation<Matrix4>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Центрируем вид сразу после построения кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToCenter(duration: const Duration(milliseconds: 100));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _transformationController.dispose();
    _entryController.dispose();
    _resetController?.dispose();
    super.dispose();
  }

  /// Плавное перемещение камеры в центр "вселенной"
  void _animateToCenter({
    Duration duration = const Duration(milliseconds: 600),
  }) {
    final size = MediaQuery.of(context).size;

    // Координаты центра контента (2000, 2000) минус половина экрана
    // Матрица смещения
    final double targetX = -2000.0 + (size.width / 2);
    final double targetY = -2000.0 + (size.height / 2);

    final Matrix4 targetMatrix = Matrix4.identity()
      ..translate(targetX, targetY)
      ..scale(1.0); // Масштаб 1.0

    _resetController?.dispose();
    _resetController = AnimationController(vsync: this, duration: duration);

    _resetAnimation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: targetMatrix,
        ).animate(
          CurvedAnimation(
            parent: _resetController!,
            curve: Curves.easeInOutCubic,
          ),
        );

    _resetAnimation!.addListener(() {
      _transformationController.value = _resetAnimation!.value;
    });

    _resetController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    final containersAsync = ref.watch(journeyContainersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Space Dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Мои Путешествия',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              ref.read(journeyContainersProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Фоновая сетка
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundGridPainter()),
          ),

          // 2. Бесконечный холст с контентом
          containersAsync.when(
            data: (containers) => _buildInfiniteCanvas(containers),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
            error: (error, stack) => _buildErrorState(),
          ),
        ],
      ),

      // 3. Кнопки управления (FAB)
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Кнопка центрирования
          FloatingActionButton(
            heroTag: 'center_btn',
            onPressed: () => _animateToCenter(),
            backgroundColor: const Color(0xFF1E293B),
            mini: true,
            child: const Icon(Icons.center_focus_strong, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Кнопка создания
          FloatingActionButton.extended(
            heroTag: 'create_btn',
            onPressed: _showCreateJourneyDialog,
            backgroundColor: const Color(0xFF6366F1),
            elevation: 10,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Новое Путешествие',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfiniteCanvas(List<JourneyContainer> containers) {
    if (containers.isEmpty) {
      return _buildEmptyState();
    }

    const double itemWidth = 320.0;
    const double itemHeight = 240.0;

    // Используем InteractiveViewer для панорамирования и зума
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(4000), // Большой запас для скролла
      minScale: 0.1,
      maxScale: 2.5,
      constrained: false, // Бесконечный канвас
      child: Container(
        width: 4000,
        height: 4000,
        // Визуализация границ "обитаемой зоны"
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.white.withOpacity(0.05), width: 1), // Для отладки можно включить
          gradient: RadialGradient(
            colors: [
              const Color(0xFF1E293B).withOpacity(0.1),
              Colors.transparent,
            ],
            radius: 0.6,
            center: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            // Рисуем связи между нодами (опционально, для стиля "созвездия")
            // ... можно добавить CustomPaint здесь для линий между системами ...

            // Размещаем карточки
            for (int i = 0; i < containers.length; i++)
              _positionContainerNode(containers[i], i, itemWidth, itemHeight),

            // Маркер центра (для ориентации)
            Positioned(
              left: 1995,
              top: 1995,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionContainerNode(
    JourneyContainer container,
    int index,
    double w,
    double h,
  ) {
    // Спиральная раскладка от центра (2000, 2000)
    final double angle = index * 0.9; // Угол поворота
    final double radius = 180.0 + (index * 140.0); // Расстояние от центра

    final double centerX = 2000.0;
    final double centerY = 2000.0;

    final double x = centerX + radius * cos(angle) - (w / 2);
    final double y = centerY + radius * sin(angle) - (h / 2);

    return Positioned(
      left: x,
      top: y,
      child: FadeTransition(
        opacity: _entryController,
        child: _JourneySystemCard(
          container: container,
          width: w,
          height: h,
          onTap: () => _openJourney(container),
          onLongPress: () => _showJourneyOptions(container),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_mosaic_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          Text(
            'Вселенная пуста',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Нажмите кнопку внизу, чтобы создать мир',
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Ошибка связи с космосом',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          TextButton(
            onPressed: () =>
                ref.read(journeyContainersProvider.notifier).refresh(),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  void _openJourney(JourneyContainer container) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            JourneyScreen(containerId: container.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // --- Диалоги и управление ---

  void _showJourneyOptions(JourneyContainer container) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text(
                'Редактировать',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditJourneyDialog(container);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(container);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateJourneyDialog() {
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Новое Путешествие',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Название',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Описание',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _createJourney();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showEditJourneyDialog(JourneyContainer container) {
    _nameController.text = container.name;
    _descriptionController.text = container.description ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Редактировать',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Название',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Описание',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await ref
                  .read(journeyContainersProvider.notifier)
                  .updateContainer(
                    containerId: container.id,
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(JourneyContainer container) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Удалить путешествие?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Это действие необратимо. Вся история будет удалена.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteJourney(container);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _createJourney() async {
    await ref
        .read(journeyContainersProvider.notifier)
        .createContainer(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
  }

  Future<void> _deleteJourney(JourneyContainer container) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      final branchRepository = BranchRepository(
        userId: userId,
        containerId: container.id,
      );
      final branches = await branchRepository.getBranches();
      for (final branch in branches) {
        for (final simId in branch.simulationIds) {
          await ref
              .read(lifeSimulationsProvider.notifier)
              .deleteSimulation(simId);
        }
        await branchRepository.deleteBranch(branch.branchId);
      }
      await ref
          .read(journeyContainersProvider.notifier)
          .deleteContainer(container.id);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }
}

// -----------------------------------------------------------------------------
// VISUAL COMPONENTS (CARDS & PAINTERS)
// -----------------------------------------------------------------------------

class _JourneySystemCard extends StatelessWidget {
  final JourneyContainer container;
  final double width;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _JourneySystemCard({
    required this.container,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Безопасное получение цвета
    Color baseColor;
    try {
      // Пытаемся получить цвет из модели (предполагаем поле coverColor)
      // Если модель сложная, адаптируйте доступ к полю
      final hexString = container.coverColor ?? '6366F1';
      baseColor = Color(
        int.parse('FF${hexString.replaceAll('#', '')}', radix: 16),
      );
    } catch (e) {
      baseColor = const Color(0xFF6366F1);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: baseColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Procedural Mini-Map (Preview inside)
              Positioned.fill(
                child: CustomPaint(
                  painter: _MiniMapPainter(
                    seed: container.id.hashCode,
                    nodeCount: container.simulationCount,
                    themeColor: baseColor,
                  ),
                ),
              ),

              // 2. Gradient Overlay (для читаемости текста)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0B0F19).withOpacity(0.3),
                        const Color(0xFF0B0F19).withOpacity(0.7),
                        const Color(0xFF0B0F19).withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Info Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: baseColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            size: 12,
                            color: baseColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'СИСТЕМА',
                            style: TextStyle(
                              color: baseColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Name
                    Text(
                      container.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description
                    if (container.description != null &&
                        container.description!.isNotEmpty)
                      Text(
                        container.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 12),

                    // Footer Stats
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          size: 10,
                          color: baseColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${container.simulationCount} узлов',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(container.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

// -----------------------------------------------------------------------------
// PAINTERS (Preview & Background)
// -----------------------------------------------------------------------------

/// Рисует процедурное превью структуры (дерево) внутри карточки
class _MiniMapPainter extends CustomPainter {
  final int seed;
  final int nodeCount;
  final Color themeColor;

  _MiniMapPainter({
    required this.seed,
    required this.nodeCount,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);

    final paintLine = Paint()
      ..color = themeColor.withOpacity(0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paintNode = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;

    final paintGlow = Paint()
      ..color = themeColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Корневой узел (Top Center)
    final root = Offset(size.width / 2, 40.0);

    // Рисуем корень
    canvas.drawCircle(root, 6, paintGlow);
    canvas.drawCircle(root, 3, paintNode);

    if (nodeCount <= 0) return;

    // Генерируем "ветки"
    List<Offset> currentLevelNodes = [root];
    int nodesDrawn = 0;

    // Ограничим визуальную сложность превью
    final limit = min(nodeCount, 20);

    while (nodesDrawn < limit && currentLevelNodes.isNotEmpty) {
      final parent = currentLevelNodes.removeAt(0);

      // Сколько детей у этого узла? (от 1 до 3)
      final childrenCount = rnd.nextInt(3) + 1;

      for (int i = 0; i < childrenCount; i++) {
        if (nodesDrawn >= limit) break;

        // Смещение вниз и вбок
        final double dy = 30.0 + rnd.nextDouble() * 20.0;
        final double dx = (rnd.nextDouble() - 0.5) * 60.0;

        final child = Offset(
          (parent.dx + dx).clamp(20.0, size.width - 20.0),
          (parent.dy + dy).clamp(20.0, size.height - 60.0),
        );

        // Рисуем линию
        canvas.drawLine(parent, child, paintLine);

        // Рисуем узел
        canvas.drawCircle(child, 4, paintGlow);
        canvas.drawCircle(child, 2, paintNode);

        currentLevelNodes.add(child);
        nodesDrawn++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Фоновая сетка
class _BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
