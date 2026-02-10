// lib/features/journey/journey_screen.dart
// ignore_for_file: unused_local_variable, unused_result, deprecated_member_use, library_prefixes, avoid_print, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:yauctor_ai/core/providers/auth_provider.dart';
import 'package:yauctor_ai/features/journey/models/branch_structure.dart';
import 'package:yauctor_ai/features/journey/services/branch_repository.dart';
import 'package:yauctor_ai/features/journey/models/life_simulation.dart';
import 'package:yauctor_ai/features/journey/providers/life_simulation_provider.dart';
import 'package:yauctor_ai/features/journey/screens/life_simulation_screen.dart';
import 'package:yauctor_ai/features/journey/widgets/journey_widgets.dart'
    as JourneyWidgets;
import 'package:yauctor_ai/ui/layout/main_layout.dart';
import 'package:yauctor_ai/features/journey/widgets/journey_widgets.dart';
import 'package:yauctor_ai/features/journey/widgets/journey_helpers.dart';
import 'package:yauctor_ai/features/journey/widgets/journey_models.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _loadingController;

  List<Branch> _branches = [];
  int _nextBranchColumn = 1;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Метод для обновления состояния
  void _updateBranches(List<Branch> branches, int nextBranchColumn) {
    print('DEBUG: Updating state with ${branches.length} branches');
    if (mounted) {
      setState(() {
        _branches = branches;
        _nextBranchColumn = nextBranchColumn;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetView();
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final simulations = await ref.read(lifeSimulationsProvider.future);
      await _loadBranchesFromDatabase(simulations);
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
      debugPrint('Error loading journey data: $e\n$stackTrace');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Загрузка веток из базы данных
  Future<void> _loadBranchesFromDatabase(
    List<LifeSimulation> simulations,
  ) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'User not authenticated';
      });
      return;
    }

    try {
      print('DEBUG: Loading branches for user: $userId');
      print('DEBUG: Total simulations: ${simulations.length}');

      await JourneyHelpers.loadBranchesFromDatabase(
        userId,
        simulations,
        _updateBranches,
      );

      print('DEBUG: Branches loaded: ${_branches.length}');
    } catch (e, stackTrace) {
      debugPrint('Error loading branches: $e\n$stackTrace');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load branches';
      });
    }
  }

  // УДАЛЕН НЕНУЖНЫЙ МЕТОД _loadSavedBranches

  void _resetView() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      _transformationController.value = Matrix4.identity()
        ..translate(screenWidth / 2 - 500, 100.0);
    });
  }

  void _refreshData() {
    ref.refresh(lifeSimulationsProvider);
    _loadAllData();
  }

  // Методы удаления (без изменений)
  Future<void> _deleteSimulation(String simulationId) async {
    try {
      await ref
          .read(lifeSimulationsProvider.notifier)
          .deleteSimulation(simulationId);

      setState(() {
        for (final branch in _branches) {
          branch.milestones.removeWhere((m) => m.id == simulationId);
        }
        _branches.removeWhere((branch) => branch.milestones.isEmpty);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _deleteBranch(Branch branch) async {
    try {
      for (final milestone in branch.milestones) {
        await ref
            .read(lifeSimulationsProvider.notifier)
            .deleteSimulation(milestone.id);
      }

      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await JourneyHelpers.deleteBranchFromDatabase(userId, branch.id);
      }

      setState(() {
        _branches.remove(branch);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления ветки: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _deleteNode(Branch branch, int nodeIndex) async {
    try {
      final milestone = branch.milestones[nodeIndex];

      await ref
          .read(lifeSimulationsProvider.notifier)
          .deleteSimulation(milestone.id);

      setState(() {
        branch.milestones.removeAt(nodeIndex);
      });

      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        if (branch.milestones.isEmpty) {
          await JourneyHelpers.deleteBranchFromDatabase(userId, branch.id);
          _branches.remove(branch);
        } else {
          await JourneyHelpers.updateBranchInDatabase(userId, branch);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления узла: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // Методы создания веток (без изменений)
  Future<void> _createNewMainBranchSimulation() async {
    final result = await Navigator.of(context).push<LifeSimulation>(
      MaterialPageRoute(builder: (_) => const LifeSimulationScreen()),
    );

    if (result != null && mounted) {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;

      final newBranch = Branch(
        id: const Uuid().v4(),
        column: _nextBranchColumn,
        row: 0,
        milestones: [JourneyHelpers.convertSimulationToMilestone(result)],
        isVertical: true,
        direction: BranchDirection.none,
      );

      await JourneyHelpers.saveBranchToDatabase(
        userId,
        BranchStructure(
          userId: userId,
          branchId: newBranch.id,
          column: newBranch.column,
          row: newBranch.row,
          isVertical: newBranch.isVertical,
          direction: newBranch.direction.name,
          simulationIds: newBranch.milestones.map((m) => m.id).toList(),
        ),
      );

      setState(() {
        _branches.add(newBranch);
        _nextBranchColumn++;
      });

      ref.refresh(lifeSimulationsProvider);
    }
  }

  Future<void> _continueVerticalBranch(Branch branch) async {
    final result = await Navigator.of(context).push<LifeSimulation>(
      MaterialPageRoute(builder: (_) => const LifeSimulationScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        branch.milestones.add(
          JourneyHelpers.convertSimulationToMilestone(result),
        );
      });

      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await JourneyHelpers.updateBranchInDatabase(userId, branch);
      }

      ref.refresh(lifeSimulationsProvider);
    }
  }

  Future<void> _createBranchFromMilestone(
    Branch parentBranch,
    int milestoneIndex, {
    required BranchDirection direction,
  }) async {
    print(
      'DEBUG: Creating branch from milestone $milestoneIndex, direction: $direction',
    );

    final result = await Navigator.of(context).push<LifeSimulation>(
      MaterialPageRoute(builder: (_) => const LifeSimulationScreen()),
    );

    if (result != null && mounted) {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;

      final newBranch = Branch(
        id: const Uuid().v4(),
        column:
            parentBranch.column + (direction == BranchDirection.left ? -1 : 1),
        row: milestoneIndex,
        milestones: [JourneyHelpers.convertSimulationToMilestone(result)],
        parentBranch: parentBranch,
        parentMilestoneIndex: milestoneIndex,
        isVertical: false,
        direction: direction,
      );

      await JourneyHelpers.saveBranchToDatabase(
        userId,
        BranchStructure(
          userId: userId,
          branchId: newBranch.id,
          parentBranchId: parentBranch.id,
          column: newBranch.column,
          row: newBranch.row,
          isVertical: newBranch.isVertical,
          direction: newBranch.direction.name,
          simulationIds: newBranch.milestones.map((m) => m.id).toList(),
        ),
      );

      setState(() {
        _branches.add(newBranch);
      });

      ref.refresh(lifeSimulationsProvider);
    }
  }

  Future<void> _continueHorizontalBranch(Branch branch) async {
    final result = await Navigator.of(context).push<LifeSimulation>(
      MaterialPageRoute(builder: (_) => const LifeSimulationScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        branch.milestones.add(
          JourneyHelpers.convertSimulationToMilestone(result),
        );
      });

      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await JourneyHelpers.updateBranchInDatabase(userId, branch);
      }

      ref.refresh(lifeSimulationsProvider);
    }
  }

  Future<void> _continueMainBranch(Branch branch) async {
    final result = await Navigator.of(context).push<LifeSimulation>(
      MaterialPageRoute(builder: (_) => const LifeSimulationScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        branch.milestones.add(
          JourneyHelpers.convertSimulationToMilestone(result),
        );
      });

      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await JourneyHelpers.updateBranchInDatabase(userId, branch);
      }

      ref.refresh(lifeSimulationsProvider);
    }
  }

  // Диалоги (без изменений)
  void _showDeleteSimulationDialog(LifeSimulation simulation) {
    JourneyHelpers.showDeleteSimulationDialog(
      context,
      simulation,
      () => _deleteSimulation(simulation.id),
    );
  }

  void _showDeleteBranchDialog(Branch branch) {
    JourneyHelpers.showDeleteBranchDialog(
      context,
      branch,
      () => _deleteBranch(branch),
    );
  }

  void _showDeleteNodeDialog(Branch branch, int nodeIndex) {
    JourneyHelpers.showDeleteNodeDialog(
      context,
      branch.milestones[nodeIndex],
      () => _deleteNode(branch, nodeIndex),
    );
  }

  // Построение UI (без изменений)
  @override
  Widget build(BuildContext context) {
    final simulationsAsync = ref.watch(lifeSimulationsProvider);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    if (_isLoading) {
      return JourneyWidgets.buildLoadingScreen(_loadingController);
    }

    if (_hasError) {
      return JourneyWidgets.buildErrorScreen(
        context,
        _errorMessage,
        _refreshData,
      );
    }

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
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainLayout()),
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
            onPressed: _refreshData,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: Colors.white),
            onPressed: _resetView,
            tooltip: 'Центрировать',
          ),
        ],
      ),
      body: _buildContent(simulationsAsync),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewMainBranchSimulation(),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'Новая симуляция',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<LifeSimulation>> simulationsAsync) {
    return simulationsAsync.when(
      data: (simulations) => _buildJourneyContent(simulations),
      loading: () => JourneyWidgets.buildLoadingScreen(_loadingController),
      error: (error, stackTrace) =>
          JourneyWidgets.buildErrorScreen(context, _errorMessage, _refreshData),
    );
  }

  Widget _buildJourneyContent(List<LifeSimulation> simulations) {
    // Разделяем ветки на вертикальные и горизонтальные
    final verticalBranches = _branches.where((b) => b.isVertical).toList();
    final horizontalBranches = _branches.where((b) => !b.isVertical).toList();

    // Находим главную ветку (column == 0)
    final mainBranch = verticalBranches.firstWhere(
      (branch) => branch.column == 0,
      orElse: () => verticalBranches.isNotEmpty
          ? verticalBranches.first
          : Branch(
              id: 'empty',
              column: 0,
              row: 0,
              milestones: [],
              isVertical: true,
              direction: BranchDirection.none,
            ),
    );

    // Остальные вертикальные ветки (не главная)
    final otherVerticalBranches = verticalBranches
        .where((b) => b.column != 0)
        .toList();

    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(3000),
          minScale: 0.5,
          maxScale: 2.0,
          constrained: false,
          child: Container(
            width: 6000,
            height: 6000,
            color: const Color(0xFF0B0F19),
            child: Stack(
              children: [
                JourneyWidgets.buildBackgroundGrid(),
                // 1. Сначала рисуем главную ветку
                if (mainBranch.milestones.isNotEmpty)
                  _buildMainBranch(mainBranch),
                // 2. Затем горизонтальные ветки (ответвления)
                ...horizontalBranches.map(
                  (branch) => _buildHorizontalBranch(branch),
                ),
                // 3. Затем остальные вертикальные ветки
                ...otherVerticalBranches.map(
                  (branch) => _buildVerticalBranch(branch),
                ),
                // 4. Пустой стартовый узел если нет симуляций
                if (simulations.isEmpty)
                  Positioned(
                    left: 800,
                    top: 200,
                    child: JourneyWidgets.buildEmptyStartNode(),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: JourneyWidgets.buildControlsHint(),
        ),
      ],
    );
  }

  Widget _buildMainBranch(Branch branch) {
    const double startX = 800.0;
    const double startY = 200.0;
    const double verticalSpacing = 280.0;

    return Stack(
      children: [
        Positioned(
          left: startX,
          top: startY,
          child: CustomPaint(
            size: Size(44, branch.milestones.length * verticalSpacing),
            painter: VerticalBranchLinePainter(isActive: true),
          ),
        ),
        for (int i = 0; i < branch.milestones.length; i++)
          Positioned(
            left: startX,
            top: startY + i * verticalSpacing,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (i < branch.milestones.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: NewBranchButton(
                      onPressed: () => _createBranchFromMilestone(
                        branch,
                        i,
                        direction: BranchDirection.left,
                      ),
                      size: 40,
                      tooltip: 'Ответвление влево',
                    ),
                  )
                else
                  const SizedBox(width: 52),
                GestureDetector(
                  onLongPress: () => _showDeleteNodeDialog(branch, i),
                  child: GlowingNode(
                    isActive: true,
                    icon: Icons.radio_button_checked,
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onLongPress: () => _showDeleteSimulationDialog(
                    branch.milestones[i].simulation,
                  ),
                  child: MilestoneCard(
                    milestone: branch.milestones[i],
                    onDelete: () => _showDeleteSimulationDialog(
                      branch.milestones[i].simulation,
                    ),
                  ),
                ),
                if (i < branch.milestones.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: NewBranchButton(
                      onPressed: () => _createBranchFromMilestone(
                        branch,
                        i,
                        direction: BranchDirection.right,
                      ),
                      size: 40,
                      tooltip: 'Ответвление вправо',
                    ),
                  ),
              ],
            ),
          ),
        Positioned(
          left: startX,
          top: startY + branch.milestones.length * verticalSpacing,
          child: NewBranchButton(
            onPressed: () => _continueMainBranch(branch),
            size: 60,
            tooltip: 'Продолжить основную ветку',
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalBranch(Branch branch) {
    const double startX = 800.0;
    const double startY = 200.0;
    const double columnWidth = 600.0;
    const double verticalSpacing = 280.0;

    final branchStartX = startX + branch.column * columnWidth;

    return Stack(
      children: [
        Positioned(
          left: branchStartX,
          top: startY,
          child: GestureDetector(
            onLongPress: () => _showDeleteBranchDialog(branch),
            child: CustomPaint(
              size: Size(44, branch.milestones.length * verticalSpacing),
              painter: VerticalBranchLinePainter(isActive: true),
            ),
          ),
        ),
        for (int i = 0; i < branch.milestones.length; i++)
          Positioned(
            left: branchStartX,
            top: startY + i * verticalSpacing,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (i < branch.milestones.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: NewBranchButton(
                      onPressed: () => _createBranchFromMilestone(
                        branch,
                        i,
                        direction: BranchDirection.left,
                      ),
                      size: 40,
                      tooltip: 'Ответвление влево',
                    ),
                  )
                else
                  const SizedBox(width: 52),
                GestureDetector(
                  onLongPress: () => _showDeleteNodeDialog(branch, i),
                  child: GlowingNode(isActive: true, icon: Icons.account_tree),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onLongPress: () => _showDeleteSimulationDialog(
                    branch.milestones[i].simulation,
                  ),
                  child: MilestoneCard(
                    milestone: branch.milestones[i],
                    onDelete: () => _showDeleteSimulationDialog(
                      branch.milestones[i].simulation,
                    ),
                  ),
                ),
                if (i < branch.milestones.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: NewBranchButton(
                      onPressed: () => _createBranchFromMilestone(
                        branch,
                        i,
                        direction: BranchDirection.right,
                      ),
                      size: 40,
                      tooltip: 'Ответвление вправо',
                    ),
                  ),
              ],
            ),
          ),
        Positioned(
          left: branchStartX,
          top: startY + branch.milestones.length * verticalSpacing,
          child: Row(
            children: [
              NewBranchButton(
                onPressed: () => _continueVerticalBranch(branch),
                size: 60,
                tooltip: 'Продолжить ветку',
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDeleteBranchDialog(branch),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.5),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalBranch(Branch branch) {
    const double startX = 800.0;
    const double startY = 200.0;
    const double columnWidth = 600.0;
    const double verticalSpacing = 280.0;
    const double horizontalSpacing = 380.0;
    const double branchOffsetY = 140.0;

    // Вычисляем позицию родительского узла
    final parentColumn = branch.parentBranch?.column ?? branch.column;
    final parentRow = branch.parentMilestoneIndex ?? branch.row;

    final parentX = startX + parentColumn * columnWidth;
    final parentY =
        startY + parentRow * verticalSpacing + 22; // +22 для центра узла

    // Определяем направление ветки
    final isLeft = branch.direction == BranchDirection.left;

    // Начальная позиция горизонтальной ветки
    final branchStartX = isLeft
        ? parentX - horizontalSpacing
        : parentX + 44 + 24 + 280 + 12; // Отступ от правой стороны карточки
    final branchStartY = parentY + branchOffsetY;

    return Stack(
      children: [
        // Соединительная линия от родительского узла к горизонтальной ветке
        Positioned(
          left: isLeft ? branchStartX + 44 : parentX + 44,
          top: parentY,
          child: CustomPaint(
            size: Size((branchStartX - parentX).abs(), branchOffsetY),
            painter: ConnectorLinePainter(direction: branch.direction),
          ),
        ),
        // Горизонтальная линия ветки
        Positioned(
          left: isLeft
              ? branchStartX -
                    (branch.milestones.length - 1) * horizontalSpacing
              : branchStartX,
          top: branchStartY,
          child: CustomPaint(
            size: Size(branch.milestones.length * horizontalSpacing, 44),
            painter: HorizontalBranchLinePainter(isActive: true),
          ),
        ),
        // Узлы и карточки вдоль горизонтальной ветки
        for (int i = 0; i < branch.milestones.length; i++)
          Positioned(
            left: isLeft
                ? branchStartX - i * horizontalSpacing
                : branchStartX + i * horizontalSpacing,
            top: branchStartY,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showDeleteNodeDialog(branch, i),
                  child: GlowingNode(isActive: true, icon: Icons.alt_route),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onLongPress: () => _showDeleteSimulationDialog(
                    branch.milestones[i].simulation,
                  ),
                  child: MilestoneCard(
                    milestone: branch.milestones[i],
                    onDelete: () => _showDeleteSimulationDialog(
                      branch.milestones[i].simulation,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Кнопка продолжения и удаления в конце ветки
        Positioned(
          left: isLeft
              ? branchStartX - branch.milestones.length * horizontalSpacing
              : branchStartX + branch.milestones.length * horizontalSpacing,
          top: branchStartY,
          child: Row(
            children: [
              NewBranchButton(
                onPressed: () => _continueHorizontalBranch(branch),
                size: 60,
                tooltip: 'Продолжить ответвление',
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDeleteBranchDialog(branch),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.5),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
