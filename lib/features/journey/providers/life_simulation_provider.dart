// lib/features/journey/providers/life_simulation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/life_simulation.dart';
import '../services/life_simulation_repository.dart';
import '../services/simulation_calculator.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/providers/auth_provider.dart';

// Провайдер репозитория с зависимостью от пользователя
final lifeSimulationRepositoryProvider = Provider<LifeSimulationRepository?>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    Log.w('LifeSimulationRepository: User not authenticated');
    return null;
  }
  return LifeSimulationRepository(userId: userId);
});

// Главный провайдер списка симуляций
final lifeSimulationsProvider =
    AsyncNotifierProvider<LifeSimulationsNotifier, List<LifeSimulation>>(
      LifeSimulationsNotifier.new,
    );

class LifeSimulationsNotifier extends AsyncNotifier<List<LifeSimulation>> {
  LifeSimulationRepository? get _repository =>
      ref.read(lifeSimulationRepositoryProvider);

  @override
  Future<List<LifeSimulation>> build() async {
    final repository = _repository;
    if (repository == null) {
      Log.w(
        'LifeSimulationsNotifier: Repository is null (user not authenticated)',
      );
      return [];
    }

    try {
      return await repository.getSimulations();
    } catch (e, stackTrace) {
      Log.e('Error building simulations', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Создание новой симуляции из ответов
  Future<LifeSimulation?> createSimulation(
    Map<String, dynamic> answers, {
    String? parentSimulationId,
    Map<String, dynamic>? branchInfo,
  }) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot create simulation: User not authenticated');
      return null;
    }

    state = const AsyncValue.loading();

    try {
      // Обрабатываем ответы через калькулятор с информацией о ветках
      final simulation = SimulationCalculator.processSimulation(
        userId: repository.userId,
        answers: answers,
        parentSimulationId: parentSimulationId,
        branchInfo: branchInfo,
      );

      // Сохраняем в Supabase
      await repository.saveSimulation(simulation);

      // Сохраняем информацию о ветках если есть
      if (parentSimulationId != null || branchInfo != null) {
        await repository.saveBranchInfo(
          simulationId: simulation.id,
          branchInfo: {
            'parent_simulation_id': parentSimulationId,
            'branch_data': branchInfo,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Обновляем состояние
      final simulations = await repository.getSimulations();
      state = AsyncValue.data(simulations);

      return simulation;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error creating simulation', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Добавим метод для удаления с очисткой связей
  Future<void> deleteSimulationWithConnections(String id) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot delete simulation: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Удаляем информацию о ветках
      await repository.deleteBranchInfo(id);

      // Удаляем симуляцию
      await repository.deleteSimulation(id);

      // Обновляем список
      final simulations = await repository.getSimulations();
      state = AsyncValue.data(simulations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e(
        'Error deleting simulation with connections',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Удаление симуляции
  Future<void> deleteSimulation(String id) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot delete simulation: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.deleteSimulation(id);
      final simulations = await repository.getSimulations();
      state = AsyncValue.data(simulations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error deleting simulation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Обновление списка
  Future<void> refresh() async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot refresh: User not authenticated');
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.syncWithCloud();
      final simulations = await repository.getSimulations();
      state = AsyncValue.data(simulations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error refreshing simulations', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

// Провайдер последней симуляции
final latestSimulationProvider = FutureProvider<LifeSimulation?>((ref) async {
  final repository = ref.read(lifeSimulationRepositoryProvider);
  if (repository == null) return null;
  return await repository.getLatestSimulation();
});

// Провайдер количества симуляций
final simulationCountProvider = Provider<int>((ref) {
  final simulations = ref.watch(lifeSimulationsProvider);
  return simulations.when(
    data: (data) => data.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

// Провайдер статистики
final simulationStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.read(lifeSimulationRepositoryProvider);
  if (repository == null) {
    return {
      'total': 0,
      'thisMonth': 0,
      'avgScore': 0.0,
      'topCategories': <String>[],
    };
  }
  return await repository.getStatistics();
});

// Провайдер текущих вопросов для симуляции
final simulationQuestionsProvider = Provider<List<SimulationQuestion>>((ref) {
  return SimulationQuestions.getDefaultQuestions();
});

// Провайдер состояния прохождения симуляции
final simulationStateProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

// Провайдер прогресса прохождения симуляции (сколько вопросов отвечено)
final simulationProgressProvider = Provider<double>((ref) {
  final state = ref.watch(simulationStateProvider);
  final questions = ref.watch(simulationQuestionsProvider);

  if (questions.isEmpty) return 0.0;

  final answeredCount = state.keys.length;
  return answeredCount / questions.length;
});
