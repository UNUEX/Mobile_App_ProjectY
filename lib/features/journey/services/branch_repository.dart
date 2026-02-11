// lib/features/journey/services/branch_repository.dart
// ignore_for_file: avoid_print, unused_field, unnecessary_type_check, dead_code, unused_local_variable

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/branch_structure.dart';
import '../../../core/utils/logger_service.dart';

class BranchRepository {
  final String userId;
  final String? containerId; // Фильтр по контейнеру
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  BranchRepository({required this.userId, this.containerId});

  // Сохранение ветки
  Future<void> saveBranch(BranchStructure branch) async {
    try {
      // ПРОВЕРЯЕМ simulation_ids
      final simulationIds = branch.simulationIds;

      final data = {
        'id': branch.id,
        'user_id': branch.userId,
        'branch_id': branch.branchId,
        'parent_branch_id': branch.parentBranchId,
        'container_id': branch.containerId,
        'column': branch.column,
        'row': branch.row,
        'is_vertical': branch.isVertical,
        'direction': branch.direction,
        'simulation_ids': simulationIds, // Убедимся что это List<String>
        'created_at': branch.createdAt.toIso8601String(),
        'updated_at': branch.updatedAt.toIso8601String(),
      };

      print('DEBUG: Saving branch to database: ${branch.branchId}');
      print('DEBUG: simulation_ids type: ${simulationIds.runtimeType}');
      print('DEBUG: simulation_ids: $simulationIds');

      // Проверяем каждое значение
      for (var i = 0; i < simulationIds.length; i++) {
        if (simulationIds[i] is! String) {
          print('ERROR: simulation_ids[$i] is not String: ${simulationIds[i]}');
        }
      }

      // Используем безопасную вставку
      final response = await _supabase.from('branches').insert(data);

      print('DEBUG: Insert successful');
      Log.i('Branch inserted: ${branch.branchId}');
    } catch (e, stackTrace) {
      Log.e('Error saving branch', error: e, stackTrace: stackTrace);

      // Дополнительная отладка
      print('FULL ERROR: $e');
      print('BRANCH DATA: ${branch.toJson()}');

      rethrow;
    }
  }

  // Получение всех веток пользователя (с фильтром по контейнеру если указан)
  Future<List<BranchStructure>> getBranches() async {
    try {
      print(
        'DEBUG: Fetching branches for user: $userId, container: $containerId',
      );

      var query = _supabase.from('branches').select().eq('user_id', userId);

      // Фильтруем по containerId если указан
      if (containerId != null) {
        query = query.eq('container_id', containerId!);
      }

      List<dynamic> response = await query.order('created_at', ascending: true);

      final branches = <BranchStructure>[];

      for (final item in response) {
        try {
          final branch = BranchStructure.fromJson(item);
          branches.add(branch);
        } catch (e) {
          Log.e('Error parsing branch: $e\nItem: $item');
        }
      }

      print('DEBUG: Found ${branches.length} branches');
      return branches;
    } catch (e, stackTrace) {
      Log.e('Error fetching branches', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Получение ветки по ID
  Future<BranchStructure?> getBranchById(String branchId) async {
    try {
      final response = await _supabase
          .from('branches')
          .select()
          .eq('user_id', userId)
          .eq('branch_id', branchId)
          .maybeSingle();

      if (response != null) {
        return BranchStructure.fromJson(response);
      }
      return null;
    } catch (e, stackTrace) {
      Log.e('Error fetching branch by ID', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Обновление списка симуляций в ветке
  Future<void> updateBranchSimulations(
    String branchId,
    List<String> simulationIds,
  ) async {
    try {
      await _supabase
          .from('branches')
          .update({
            'simulation_ids': simulationIds,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('branch_id', branchId);
    } catch (e, stackTrace) {
      Log.e(
        'Error updating branch simulations',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Удаление ветки
  Future<void> deleteBranch(String branchId) async {
    try {
      await _supabase
          .from('branches')
          .delete()
          .eq('user_id', userId)
          .eq('branch_id', branchId);
      Log.i('Branch deleted: $branchId');
    } catch (e, stackTrace) {
      Log.e('Error deleting branch', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Удаление всех веток пользователя
  Future<void> deleteAllBranches() async {
    try {
      var query = _supabase.from('branches').delete().eq('user_id', userId);

      if (containerId != null) {
        query = query.eq('container_id', containerId!);
      }

      await query;
      Log.i('All branches deleted for user: $userId, container: $containerId');
    } catch (e, stackTrace) {
      Log.e('Error deleting all branches', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Удаление всех веток контейнера
  Future<void> deleteAllBranchesInContainer(String containerId) async {
    try {
      await _supabase
          .from('branches')
          .delete()
          .eq('user_id', userId)
          .eq('container_id', containerId);
      Log.i('All branches deleted for container: $containerId');
    } catch (e, stackTrace) {
      Log.e(
        'Error deleting container branches',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Получение максимального значения column
  Future<int> getMaxColumn() async {
    try {
      var query = _supabase
          .from('branches')
          .select('column')
          .eq('user_id', userId);

      if (containerId != null) {
        query = query.eq('container_id', containerId!);
      }

      final response = await query
          .order('column', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final columnValue = response['column'];
        if (columnValue != null) {
          return (columnValue as num).toInt();
        }
      }
      return 0;
    } catch (e, stackTrace) {
      Log.e('Error getting max column', error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  // Проверка существования ветки
  Future<bool> branchExists(String branchId) async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id')
          .eq('user_id', userId)
          .eq('branch_id', branchId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      Log.e(
        'Error checking if branch exists',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Получить все симуляции, которые уже находятся в ветках
  Future<Set<String>> getAllSimulationIdsInBranches() async {
    try {
      var query = _supabase
          .from('branches')
          .select('simulation_ids')
          .eq('user_id', userId);

      if (containerId != null) {
        query = query.eq('container_id', containerId!);
      }

      final response = await query;

      final allSimulationIds = <String>{};

      for (final item in response) {
        final simulationIds = List<String>.from(item['simulation_ids'] ?? []);
        allSimulationIds.addAll(simulationIds);
      }

      return allSimulationIds;
    } catch (e, stackTrace) {
      Log.e(
        'Error getting all simulation ids in branches',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  // Получить симуляции без веток
  Future<List<String>> getOrphanedSimulationIds(
    List<String> allSimulationIds,
  ) async {
    try {
      final simulationIdsInBranches = await getAllSimulationIdsInBranches();
      return allSimulationIds
          .where((id) => !simulationIdsInBranches.contains(id))
          .toList();
    } catch (e, stackTrace) {
      Log.e(
        'Error getting orphaned simulation ids',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Проверить, существует ли ветка с определенным branchId
  Future<bool> branchExistsByBranchId(String branchId) async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id')
          .eq('user_id', userId)
          .eq('branch_id', branchId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      Log.e(
        'Error checking if branch exists by branchId',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Получить ветку по branchId с проверкой
  Future<BranchStructure?> getBranchByBranchId(String branchId) async {
    try {
      final response = await _supabase
          .from('branches')
          .select()
          .eq('user_id', userId)
          .eq('branch_id', branchId)
          .maybeSingle();

      if (response != null) {
        return BranchStructure.fromJson(response);
      }
      return null;
    } catch (e, stackTrace) {
      Log.e(
        'Error fetching branch by branchId',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // Обновить позицию ветки
  Future<void> updateBranchPosition(
    String branchId,
    int column,
    int row,
  ) async {
    try {
      await _supabase
          .from('branches')
          .update({
            'column': column,
            'row': row,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('branch_id', branchId);
    } catch (e, stackTrace) {
      Log.e('Error updating branch position', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Удалить все ветки для определенных simulationIds
  Future<void> deleteBranchesForSimulations(List<String> simulationIds) async {
    try {
      for (final simulationId in simulationIds) {
        await _supabase
            .from('branches')
            .delete()
            .eq('user_id', userId)
            .contains('simulation_ids', [simulationId]);
      }
    } catch (e, stackTrace) {
      Log.e(
        'Error deleting branches for simulations',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Получить количество симуляций в контейнере
  Future<int> getSimulationCountInContainer(String containerId) async {
    try {
      final response = await _supabase
          .from('branches')
          .select('simulation_ids')
          .eq('user_id', userId)
          .eq('container_id', containerId);

      final allSimulationIds = <String>{};

      for (final item in response) {
        final simulationIds = List<String>.from(item['simulation_ids'] ?? []);
        allSimulationIds.addAll(simulationIds);
      }

      return allSimulationIds.length;
    } catch (e, stackTrace) {
      Log.e(
        'Error getting simulation count in container',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }
}
