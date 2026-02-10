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
  final Branch? parentBranch;
  final int? parentMilestoneIndex;
  final bool isVertical;
  final BranchDirection direction;

  Branch({
    required this.id,
    required this.column,
    required this.row,
    required this.milestones,
    this.parentBranch,
    this.parentMilestoneIndex,
    required this.isVertical,
    required this.direction,
  });
}
