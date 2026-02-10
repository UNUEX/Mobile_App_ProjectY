// lib/features/journey/widgets/journey_helpers.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/branch_structure.dart';
import '../services/branch_repository.dart';
import '../models/life_simulation.dart';
import 'journey_models.dart';

class JourneyHelpers {
  // Форматирование даты
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // Преобразование симуляции в веху
  static Milestone convertSimulationToMilestone(LifeSimulation simulation) {
    return Milestone(
      id: simulation.id,
      title: simulation.title,
      description: simulation.summary.isNotEmpty
          ? simulation.summary
          : 'Симуляция жизни',
      date: formatDate(simulation.createdAt),
      score: simulation.results['totalScore'] as double? ?? 0.0,
      simulation: simulation,
    );
  }

  // ПРЕОБРАЗОВАНИЕ СПИСКА СИМУЛЯЦИЙ В ВЕХИ (ДОБАВЛЕНО)
  static List<Milestone> convertSimulationsToMilestones(
    List<LifeSimulation> simulations,
  ) {
    return simulations
        .map((simulation) => convertSimulationToMilestone(simulation))
        .toList();
  }

  // ЗАГРУЗКА ВЕТОК ИЗ БАЗЫ ДАННЫХ
  static Future<void> loadBranchesFromDatabase(
    String userId,
    List<LifeSimulation> simulations,
    void Function(List<Branch>, int) updateState,
  ) async {
    try {
      final branchRepository = BranchRepository(userId: userId);
      print('DEBUG: Starting branch loading for user: $userId');

      // Получаем ветки из базы
      final branchStructures = await branchRepository.getBranches();
      print('DEBUG: Got ${branchStructures.length} branches from DB');

      if (branchStructures.isEmpty && simulations.isNotEmpty) {
        print('DEBUG: No branches in DB, creating from simulations');
        // Создаем простые ветки для каждой симуляции
        final branches = <Branch>[];
        int column = 0;

        // Сортируем симуляции по дате создания
        final sortedSimulations = List<LifeSimulation>.from(simulations)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        for (final simulation in sortedSimulations) {
          final branch = Branch(
            id: const Uuid().v4(),
            column: column,
            row: 0,
            milestones: [convertSimulationToMilestone(simulation)],
            isVertical: true,
            direction: BranchDirection.none,
          );
          branches.add(branch);
          column++;

          // Сохраняем в базу
          await saveBranchToDatabase(
            userId,
            BranchStructure(
              userId: userId,
              branchId: branch.id,
              column: branch.column,
              row: branch.row,
              isVertical: branch.isVertical,
              direction: branch.direction.name,
              simulationIds: branch.milestones.map((m) => m.id).toList(),
            ),
          );
        }

        updateState(branches, column);
        return;
      }

      // Если ветки есть в базе, загружаем их
      if (branchStructures.isNotEmpty) {
        print('DEBUG: Processing ${branchStructures.length} branch structures');

        final simulationMap = <String, LifeSimulation>{};
        for (final sim in simulations) {
          simulationMap[sim.id] = sim;
        }

        final branches = <Branch>[];
        int maxColumn = 0;

        for (final branchStructure in branchStructures) {
          final milestones = <Milestone>[];

          for (final simId in branchStructure.simulationIds) {
            final simulation = simulationMap[simId];
            if (simulation != null) {
              milestones.add(convertSimulationToMilestone(simulation));
            }
          }

          if (milestones.isNotEmpty) {
            final branch = Branch(
              id: branchStructure.branchId,
              column: branchStructure.column,
              row: branchStructure.row,
              milestones: milestones,
              isVertical: branchStructure.isVertical,
              direction: _parseBranchDirection(branchStructure.direction),
            );
            branches.add(branch);

            if (branchStructure.column > maxColumn) {
              maxColumn = branchStructure.column;
            }
          }
        }

        print('DEBUG: Created ${branches.length} branches from DB');
        updateState(branches, maxColumn + 1);
      } else {
        print('DEBUG: No branches and no simulations');
        updateState([], 1);
      }
    } catch (e) {
      print('ERROR in loadBranchesFromDatabase: $e');
      // В случае ошибки возвращаем пустой список
      updateState([], 1);
    }
  }

  static BranchDirection _parseBranchDirection(String direction) {
    switch (direction.toLowerCase()) {
      case 'left':
        return BranchDirection.left;
      case 'right':
        return BranchDirection.right;
      default:
        return BranchDirection.none;
    }
  }

  // Работа с базой данных
  static Future<void> saveBranchToDatabase(
    String userId,
    BranchStructure branch,
  ) async {
    try {
      final branchRepository = BranchRepository(userId: userId);
      await branchRepository.saveBranch(branch);
      print('DEBUG: Saved branch ${branch.branchId} to database');
    } catch (e) {
      print('Error saving branch to database: $e');
      rethrow;
    }
  }

  static Future<void> updateBranchInDatabase(
    String userId,
    Branch branch,
  ) async {
    try {
      final branchRepository = BranchRepository(userId: userId);
      await branchRepository.updateBranchSimulations(
        branch.id,
        branch.milestones.map((m) => m.id).toList(),
      );
      print('DEBUG: Updated branch ${branch.id} in database');
    } catch (e) {
      print('Error updating branch in database: $e');
      rethrow;
    }
  }

  static Future<void> deleteBranchFromDatabase(
    String userId,
    String branchId,
  ) async {
    try {
      final branchRepository = BranchRepository(userId: userId);
      await branchRepository.deleteBranch(branchId);
      print('DEBUG: Deleted branch $branchId from database');
    } catch (e) {
      print('Error deleting branch from database: $e');
      rethrow;
    }
  }

  // Диалоги
  static void showDeleteSimulationDialog(
    BuildContext context,
    LifeSimulation simulation,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Удалить симуляцию?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Вы уверены, что хотите удалить симуляцию "${simulation.title}"?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  static void showDeleteBranchDialog(
    BuildContext context,
    Branch branch,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Удалить ветку?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          branch.isVertical
              ? 'Вы уверены, что хотите удалить эту ветку с ${branch.milestones.length} симуляциями?'
              : 'Вы уверены, что хотите удалить это ответвление?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  static void showDeleteNodeDialog(
    BuildContext context,
    Milestone milestone,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Удалить узел?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Вы уверены, что хотите удалить узел "${milestone.title}"? Симуляция также будет удалена.',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
