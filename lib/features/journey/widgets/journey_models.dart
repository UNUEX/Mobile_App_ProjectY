// lib/features/journey/widgets/journey_models.dart
import '../models/life_simulation.dart';

enum BranchDirection { left, right, none }

class Milestone {
  final String id;
  final String title;
  final String description;
  final String date;
  final double score;
  final LifeSimulation simulation;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.score,
    required this.simulation,
  });
}

class Branch {
  final String id;
  final int column;
  final int row;
  final List<Milestone> milestones;
  final bool isVertical;
  final BranchDirection direction;
  final String? parentBranchId;
  final String? containerId;
  Branch? parentBranch;
  int? parentMilestoneIndex;

  Branch({
    required this.id,
    required this.column,
    required this.row,
    required this.milestones,
    required this.isVertical,
    required this.direction,
    this.parentBranchId,
    this.containerId,
    this.parentBranch,
    this.parentMilestoneIndex,
  });

  // Геттер для определения, является ли ветка top-level
  bool get isTopLevel => parentBranchId == null;
}
