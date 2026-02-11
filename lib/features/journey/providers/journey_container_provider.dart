// lib/features/journey/providers/journey_container_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journey_container.dart';
import '../services/journey_container_repository.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/providers/auth_provider.dart';

/// Провайдер репозитория контейнеров
final journeyContainerRepositoryProvider =
    Provider<JourneyContainerRepository?>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        Log.w('JourneyContainerRepository: User not authenticated');
        return null;
      }
      return JourneyContainerRepository(userId: userId);
    });

/// Главный провайдер списка контейнеров
final journeyContainersProvider =
    AsyncNotifierProvider<JourneyContainersNotifier, List<JourneyContainer>>(
      JourneyContainersNotifier.new,
    );

class JourneyContainersNotifier extends AsyncNotifier<List<JourneyContainer>> {
  JourneyContainerRepository? get _repository =>
      ref.read(journeyContainerRepositoryProvider);

  @override
  Future<List<JourneyContainer>> build() async {
    final repository = _repository;
    if (repository == null) {
      Log.w('JourneyContainersNotifier: Repository is null');
      return [];
    }

    try {
      return await repository.getContainers();
    } catch (e, stackTrace) {
      Log.e('Error building containers', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Создание нового контейнера
  Future<JourneyContainer?> createContainer({
    required String name,
    String? description,
    String? coverColor,
  }) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot create container: User not authenticated');
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final container = await repository.createContainer(
        name: name,
        description: description,
        coverColor: coverColor,
      );

      // Обновляем состояние
      final containers = await repository.getContainers();
      state = AsyncValue.data(containers);

      return container;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error creating container', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Обновление контейнера
  Future<void> updateContainer({
    required String containerId,
    String? name,
    String? description,
    String? coverColor,
  }) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot update container: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.updateContainer(
        containerId: containerId,
        name: name,
        description: description,
        coverColor: coverColor,
      );

      // Обновляем состояние
      final containers = await repository.getContainers();
      state = AsyncValue.data(containers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error updating container', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Обновление счетчика симуляций
  Future<void> updateSimulationCount(String containerId, int count) async {
    final repository = _repository;
    if (repository == null) return;

    try {
      await repository.updateSimulationCount(containerId, count);

      // Обновляем состояние
      final containers = await repository.getContainers();
      state = AsyncValue.data(containers);
    } catch (e, stackTrace) {
      Log.e(
        'Error updating simulation count',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Удаление контейнера
  Future<void> deleteContainer(String containerId) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot delete container: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.deleteContainer(containerId);

      // Обновляем состояние
      final containers = await repository.getContainers();
      state = AsyncValue.data(containers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error deleting container', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Обновление списка
  Future<void> refresh() async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot refresh: User not authenticated');
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final containers = await repository.getContainers();
      state = AsyncValue.data(containers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error refreshing containers', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Провайдер количества контейнеров
final containerCountProvider = Provider<int>((ref) {
  final containers = ref.watch(journeyContainersProvider);
  return containers.when(
    data: (data) => data.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});
