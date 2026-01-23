// lib/features/home/providers/daily_reflection_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_reflection_model.dart';
import '../services/daily_reflection_repository.dart';

final dailyReflectionRepositoryProvider = Provider<DailyReflectionRepository>((
  ref,
) {
  return DailyReflectionRepository();
});

// Используем AsyncNotifierProvider вместо StateNotifierProvider
final dailyReflectionsProvider =
    AsyncNotifierProvider<DailyReflectionsNotifier, List<DailyReflectionModel>>(
      DailyReflectionsNotifier.new,
    );

class DailyReflectionsNotifier
    extends AsyncNotifier<List<DailyReflectionModel>> {
  DailyReflectionRepository get _repository =>
      ref.read(dailyReflectionRepositoryProvider);

  @override
  Future<List<DailyReflectionModel>> build() async {
    return await _repository.getReflections();
  }

  Future<void> addReflection(String text, {String? emotion}) async {
    state = const AsyncValue.loading();

    try {
      await _repository.saveReflectionFromText(text, emotion: emotion);
      final reflections = await _repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> addReflectionFromModel(DailyReflectionModel reflection) async {
    state = const AsyncValue.loading();

    try {
      await _repository.saveReflection(reflection);
      final reflections = await _repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteReflection(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteReflection(id);
      final reflections = await _repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAllReflections() async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteAllReflections();
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final reflections = await _repository.getReflections();
      state = AsyncValue.data(reflections);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

// Вспомогательные провайдеры
final hasReflectionTodayProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(dailyReflectionRepositoryProvider);
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
