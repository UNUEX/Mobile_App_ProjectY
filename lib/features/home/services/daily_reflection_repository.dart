// lib/features/home/services/daily_reflection_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_reflection_model.dart';
import '../../../core/utils/logger_service.dart';

class DailyReflectionRepository {
  static const String _storageKey = 'daily_reflections';
  static const String _legacyStorageKey = 'daily_reflections_legacy';

  Future<List<DailyReflectionModel>> getReflections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      // Пробуем загрузить новые записи
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => DailyReflectionModel.fromJson(json))
            .toList();
      }

      // Пробуем загрузить старые записи (для миграции)
      final legacyJsonString = prefs.getString(_legacyStorageKey);
      if (legacyJsonString != null && legacyJsonString.isNotEmpty) {
        final List<dynamic> legacyList = json.decode(legacyJsonString);
        final reflections = legacyList
            .map(
              (item) => DailyReflectionModel.fromLegacyFormat(
                Map<String, String>.from(item),
              ),
            )
            .toList();

        // Мигрируем в новый формат
        await _saveAllReflections(reflections);
        await prefs.remove(_legacyStorageKey);

        return reflections;
      }

      return [];
    } catch (e, stackTrace) {
      Log.e('Error loading reflections', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> saveReflection(DailyReflectionModel reflection) async {
    try {
      final reflections = await getReflections();
      // Удаляем старые записи с тем же ID (если есть)
      reflections.removeWhere((r) => r.id == reflection.id);
      reflections.insert(0, reflection); // Добавляем в начало

      await _saveAllReflections(reflections);
      Log.i('Reflection saved: ${reflection.id}');
    } catch (e, stackTrace) {
      Log.e('Error saving reflection', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> saveReflectionFromText(String text, {String? emotion}) async {
    final reflection = DailyReflectionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      date: DateTime.now(),
      emotion: emotion,
      metadata: {
        'source': 'ai_assistant',
        'savedAt': DateTime.now().toIso8601String(),
      },
    );

    await saveReflection(reflection);
  }

  Future<void> deleteReflection(String id) async {
    try {
      final reflections = await getReflections();
      reflections.removeWhere((r) => r.id == id);

      await _saveAllReflections(reflections);
      Log.i('Reflection deleted: $id');
    } catch (e, stackTrace) {
      Log.e('Error deleting reflection', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAllReflections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      Log.i('All reflections deleted');
    } catch (e, stackTrace) {
      Log.e('Error deleting all reflections', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<int> getReflectionCount() async {
    final reflections = await getReflections();
    return reflections.length;
  }

  Future<List<DailyReflectionModel>> getRecentReflections({
    int limit = 10,
  }) async {
    final reflections = await getReflections();
    return reflections.take(limit).toList();
  }

  Future<bool> hasReflectionToday() async {
    final today = DateTime.now();
    final reflections = await getReflections();

    return reflections.any((reflection) {
      return reflection.date.year == today.year &&
          reflection.date.month == today.month &&
          reflection.date.day == today.day;
    });
  }

  Future<void> _saveAllReflections(
    List<DailyReflectionModel> reflections,
  ) async {
    final jsonList = reflections.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonString);
  }
}
