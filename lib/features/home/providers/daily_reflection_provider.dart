// lib/features/home/providers/daily_reflection_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/daily_reflection_model.dart';
import '../services/daily_reflection_repository.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/providers/auth_provider.dart';

// 2. Провайдер репозитория с зависимостью от пользователя
final dailyReflectionRepositoryProvider = Provider<DailyReflectionRepository?>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    Log.w('DailyReflectionRepository: User not authenticated');
    return null;
  }
  return DailyReflectionRepository(userId: userId);
});

// 3. Главный провайдер с проверкой авторизации
final dailyReflectionsProvider =
    AsyncNotifierProvider<DailyReflectionsNotifier, List<DailyReflectionModel>>(
      DailyReflectionsNotifier.new,
    );

class DailyReflectionsNotifier
    extends AsyncNotifier<List<DailyReflectionModel>> {
  DailyReflectionRepository? get _repository =>
      ref.read(dailyReflectionRepositoryProvider);

  @override
  Future<List<DailyReflectionModel>> build() async {
    final repository = _repository;
    if (repository == null) {
      Log.w(
        'DailyReflectionsNotifier: Repository is null (user not authenticated)',
      );
      return []; // Пользователь не авторизован
    }

    try {
      // Сначала синхронизируем локальные данные
      await repository.syncLocalData();

      // Затем загружаем данные
      return await repository.getReflections();
    } catch (e, stackTrace) {
      Log.e('Error building reflections', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> addReflection(String text, {String? emotion}) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot add reflection: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.saveReflectionFromText(text, emotion: emotion);

      // Обновляем состояние
      final reflections = await repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      Log.e('Error adding reflection', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addReflectionFromModel(DailyReflectionModel reflection) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot add reflection: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.saveReflection(reflection);
      final reflections = await repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteReflection(String id) async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot delete reflection: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.deleteReflection(id);
      final reflections = await repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAllReflections() async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot delete reflections: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.deleteAllReflections();
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot refresh: User not authenticated');
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Синхронизируем перед обновлением
      await repository.syncLocalData();

      final reflections = await repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Новый метод для синхронизации
  Future<void> syncWithCloud() async {
    final repository = _repository;
    if (repository == null) {
      Log.w('Cannot sync: User not authenticated');
      return;
    }

    state = const AsyncValue.loading();

    try {
      await repository.syncLocalData();
      final reflections = await repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

// 4. Вспомогательные провайдеры
final hasReflectionTodayProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(dailyReflectionRepositoryProvider);
  if (repository == null) return false;
  return await repository.hasReflectionToday();
});

final reflectionCountProvider = Provider<int>((ref) {
  final reflections = ref.watch(dailyReflectionsProvider);
  return reflections.when(
    data: (data) => data.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

// Провайдер для получения отформатированных записей
final formattedReflectionsProvider = Provider<List<DailyReflectionModel>>((
  ref,
) {
  final reflections = ref.watch(dailyReflectionsProvider);
  return reflections.when(
    data: (data) => data,
    loading: () => [],
    error: (_, _) => [],
  );
});

// Провайдер статуса синхронизации
final syncStatusProvider = StateProvider<bool>((ref) => false);
