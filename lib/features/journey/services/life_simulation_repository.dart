// lib/features/journey/services/life_simulation_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/life_simulation.dart';
import '../../../core/utils/logger_service.dart';

class LifeSimulationRepository {
  final String userId;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Кэш для локального хранения
  List<LifeSimulation>? _cachedSimulations;

  LifeSimulationRepository({required this.userId});

  // Сохранение симуляции в Supabase
  Future<void> saveSimulation(LifeSimulation simulation) async {
    try {
      final data = {
        'id': simulation.id,
        'user_id': userId,
        'title': simulation.title,
        'answers': simulation.answers,
        'results': simulation.results,
        'summary': simulation.summary,
        'created_at': simulation.createdAt.toIso8601String(),
        'emotional_tone': simulation.emotionalTone,
        'tags': simulation.tags,
      };

      await _supabase.from('life_simulations').upsert(data);

      // Инвалидируем кэш
      _cachedSimulations = null;

      Log.i('Simulation saved successfully: ${simulation.id}');
    } catch (e, stackTrace) {
      Log.e('Error saving simulation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Получение всех симуляций пользователя
  Future<List<LifeSimulation>> getSimulations() async {
    // Проверяем кэш
    if (_cachedSimulations != null) {
      return _cachedSimulations!;
    }

    try {
      final response = await _supabase
          .from('life_simulations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final simulations = (response as List)
          .map(
            (json) => LifeSimulation.fromJson({
              'id': json['id'],
              'userId': json['user_id'],
              'title': json['title'],
              'answers': json['answers'],
              'results': json['results'],
              'summary': json['summary'],
              'createdAt': json['created_at'],
              'emotionalTone': json['emotional_tone'],
              'tags': json['tags'],
            }),
          )
          .toList();

      _cachedSimulations = simulations;
      return simulations;
    } catch (e, stackTrace) {
      Log.e('Error fetching simulations', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Получение одной симуляции по ID
  Future<LifeSimulation?> getSimulationById(String id) async {
    try {
      final response = await _supabase
          .from('life_simulations')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .single();

      return LifeSimulation.fromJson({
        'id': response['id'],
        'userId': response['user_id'],
        'title': response['title'],
        'answers': response['answers'],
        'results': response['results'],
        'summary': response['summary'],
        'createdAt': response['created_at'],
        'emotionalTone': response['emotional_tone'],
        'tags': response['tags'],
      });
    } catch (e, stackTrace) {
      Log.e(
        'Error fetching simulation by ID',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // Удаление симуляции
  Future<void> deleteSimulation(String id) async {
    try {
      await _supabase
          .from('life_simulations')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      _cachedSimulations = null;
      Log.i('Simulation deleted: $id');
    } catch (e, stackTrace) {
      Log.e('Error deleting simulation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Получение последней симуляции
  Future<LifeSimulation?> getLatestSimulation() async {
    final simulations = await getSimulations();
    return simulations.isNotEmpty ? simulations.first : null;
  }

  // Получение статистики
  Future<Map<String, dynamic>> getStatistics() async {
    final simulations = await getSimulations();

    if (simulations.isEmpty) {
      return {
        'total': 0,
        'thisMonth': 0,
        'avgScore': 0.0,
        'topCategories': <String>[],
      };
    }

    final now = DateTime.now();
    final thisMonthCount = simulations.where((s) {
      return s.createdAt.year == now.year && s.createdAt.month == now.month;
    }).length;

    // Подсчет средних значений и категорий
    final allScores = <double>[];
    final categoryCount = <String, int>{};

    for (final sim in simulations) {
      if (sim.results['categories'] != null) {
        for (final category in sim.results['categories'] as List) {
          final cat = category as Map<String, dynamic>;
          allScores.add((cat['score'] as num).toDouble());
          final catName = cat['category'] as String;
          categoryCount[catName] = (categoryCount[catName] ?? 0) + 1;
        }
      }
    }

    final avgScore = allScores.isEmpty
        ? 0.0
        : allScores.reduce((a, b) => a + b) / allScores.length;

    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total': simulations.length,
      'thisMonth': thisMonthCount,
      'avgScore': avgScore,
      'topCategories': topCategories.take(3).map((e) => e.key).toList(),
    };
  }

  // Синхронизация с облаком
  Future<void> syncWithCloud() async {
    _cachedSimulations = null;
    await getSimulations();
  }

  // Очистка кэша
  void clearCache() {
    _cachedSimulations = null;
  }
}
