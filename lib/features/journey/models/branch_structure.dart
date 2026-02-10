// lib/features/journey/models/branch_structure.dart
import 'package:uuid/uuid.dart';

class BranchStructure {
  final String id;
  final String userId;
  final String branchId;
  final String? parentBranchId;
  final int column;
  final int row;
  final bool isVertical;
  final String direction; // 'left', 'right', 'none'
  final List<String> simulationIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchStructure({
    String? id,
    required this.userId,
    required this.branchId,
    this.parentBranchId,
    required this.column,
    required this.row,
    required this.isVertical,
    required this.direction,
    required this.simulationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory BranchStructure.fromJson(Map<String, dynamic> json) {
    // Безопасное извлечение значений
    final columnValue = json['column'] ?? json['"column"'] ?? 0;
    final rowValue = json['row'] ?? json['"row"'] ?? 0;

    return BranchStructure(
      id: json['id']?.toString() ?? const Uuid().v4(),
      userId: json['user_id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      parentBranchId: json['parent_branch_id']?.toString(),
      column: (columnValue is num
          ? columnValue.toInt()
          : int.tryParse(columnValue.toString()) ?? 0),
      row: (rowValue is num
          ? rowValue.toInt()
          : int.tryParse(rowValue.toString()) ?? 0),
      isVertical: json['is_vertical'] == true,
      direction: json['direction']?.toString() ?? 'none',
      simulationIds: List<String>.from(json['simulation_ids'] ?? []),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'branch_id': branchId,
      'parent_branch_id': parentBranchId,
      'column': column,
      'row': row,
      'is_vertical': isVertical,
      'direction': direction,
      'simulation_ids': simulationIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
