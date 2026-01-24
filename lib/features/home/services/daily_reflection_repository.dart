// lib/features/home/services/daily_reflection_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_reflection_model.dart';
import '../../../core/utils/logger_service.dart';

class DailyReflectionRepository {
  static const String _storageKey = 'daily_reflections';
  static const String _legacyStorageKey = 'daily_reflections_legacy';

  final SupabaseClient _supabase;
  final String _userId;

  DailyReflectionRepository({required String userId})
    : _supabase = Supabase.instance.client,
      _userId = userId;

  // Получить все записи (сначала из кэша, потом из Supabase)
  Future<List<DailyReflectionModel>> getReflections() async {
    try {
      // Пробуем загрузить из Supabase
      final supabaseReflections = await _getReflectionsFromSupabase();

      // Если есть данные из Supabase, обновляем локальный кэш
      if (supabaseReflections.isNotEmpty) {
        await _saveAllReflectionsToLocal(supabaseReflections);
        return supabaseReflections;
      }

      // Если нет интернета или данных в Supabase, загружаем из локального хранилища
      return await _getReflectionsFromLocal();
    } catch (e, stackTrace) {
      Log.e('Error loading reflections', error: e, stackTrace: stackTrace);

      // В случае ошибки, возвращаем локальные данные
      return await _getReflectionsFromLocal();
    }
  }

  // Загрузка из Supabase
  Future<List<DailyReflectionModel>> _getReflectionsFromSupabase() async {
    try {
      final response = await _supabase
          .from('daily_reflections')
          .select()
          .eq('user_id', _userId)
          .order('date', ascending: false);

      if (response.isEmpty) return [];

      return response
          .map<DailyReflectionModel>(
            (json) => DailyReflectionModel.fromSupabase(json),
          )
          .toList();
    } catch (e) {
      Log.w('Failed to load from Supabase, using local storage: $e');
      return [];
    }
  }

  // Загрузка из локального хранилища
  Future<List<DailyReflectionModel>> _getReflectionsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      // Пробуем загрузить новые записи
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => DailyReflectionModel.fromJson(json))
            .where(
              (reflection) => reflection.userId == _userId,
            ) // Только текущего пользователя
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
                _userId,
              ),
            )
            .toList();

        // Сохраняем в новый формат
        await _saveAllReflectionsToLocal(reflections);
        await prefs.remove(_legacyStorageKey);

        return reflections;
      }

      return [];
    } catch (e, stackTrace) {
      Log.e(
        'Error loading reflections from local storage',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Сохранить запись (и в Supabase, и локально)
  Future<void> saveReflection(DailyReflectionModel reflection) async {
    try {
      // Сохраняем в Supabase
      final data = reflection.toSupabaseMap();
      await _supabase.from('daily_reflections').upsert(data, onConflict: 'id');

      // Сохраняем локально
      await _saveReflectionToLocal(reflection);

      Log.i('Reflection saved to Supabase and local: ${reflection.id}');
    } catch (e, stackTrace) {
      Log.e(
        'Error saving reflection to Supabase',
        error: e,
        stackTrace: stackTrace,
      );

      // Если ошибка сети, сохраняем только локально
      await _saveReflectionToLocal(reflection);
      Log.i('Reflection saved locally only (offline mode): ${reflection.id}');
    }
  }

  // Локальное сохранение
  Future<void> _saveReflectionToLocal(DailyReflectionModel reflection) async {
    try {
      final reflections = await _getReflectionsFromLocal();
      // Удаляем старые записи с тем же ID (если есть)
      reflections.removeWhere((r) => r.id == reflection.id);
      reflections.insert(0, reflection); // Добавляем в начало

      await _saveAllReflectionsToLocal(reflections);
    } catch (e) {
      Log.e('Error saving to local storage', error: e);
      rethrow;
    }
  }

  // Сохранить из текста (удобно для AI)
  Future<void> saveReflectionFromText(String text, {String? emotion}) async {
    final reflection = DailyReflectionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId,
      text: text,
      date: DateTime.now(),
      emotion: emotion,
      metadata: {
        'source': 'ai_assistant',
        'saved_at': DateTime.now().toIso8601String(),
        'synced': false, // Помечаем для синхронизации
      },
    );

    await saveReflection(reflection);
  }

  // Удалить запись
  Future<void> deleteReflection(String id) async {
    try {
      // Удаляем из Supabase
      await _supabase
          .from('daily_reflections')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      Log.w('Failed to delete from Supabase: $e');
      // Помечаем как удаленную локально для последующей синхронизации
    }

    // Удаляем локально
    try {
      final reflections = await _getReflectionsFromLocal();
      reflections.removeWhere((r) => r.id == id);
      await _saveAllReflectionsToLocal(reflections);

      Log.i('Reflection deleted: $id');
    } catch (e, stackTrace) {
      Log.e(
        'Error deleting reflection locally',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Удалить все записи пользователя
  Future<void> deleteAllReflections() async {
    try {
      // Удаляем из Supabase
      await _supabase.from('daily_reflections').delete().eq('user_id', _userId);
    } catch (e) {
      Log.w('Failed to delete all from Supabase: $e');
    }

    // Удаляем локально
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      // Также удаляем записи текущего пользователя из общего кэша
      final allReflections = await _getReflectionsFromLocal();
      final filteredReflections = allReflections
          .where((r) => r.userId != _userId)
          .toList();
      await _saveAllReflectionsToLocal(filteredReflections);

      Log.i('All reflections deleted for user: $_userId');
    } catch (e, stackTrace) {
      Log.e(
        'Error deleting all reflections locally',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Получить количество записей
  Future<int> getReflectionCount() async {
    final reflections = await getReflections();
    return reflections.length;
  }

  // Получить последние записи
  Future<List<DailyReflectionModel>> getRecentReflections({
    int limit = 10,
  }) async {
    final reflections = await getReflections();
    return reflections.take(limit).toList();
  }

  // Проверить, есть ли запись за сегодня
  Future<bool> hasReflectionToday() async {
    final today = DateTime.now();
    final reflections = await getReflections();

    return reflections.any((reflection) {
      return reflection.date.year == today.year &&
          reflection.date.month == today.month &&
          reflection.date.day == today.day;
    });
  }

  // Локальное сохранение всех записей
  Future<void> _saveAllReflectionsToLocal(
    List<DailyReflectionModel> reflections,
  ) async {
    final jsonList = reflections.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonString);
  }

  // Синхронизация локальных данных с Supabase
  Future<void> syncLocalData() async {
    try {
      final localReflections = await _getReflectionsFromLocal();

      // Фильтруем только записи текущего пользователя
      final userReflections = localReflections
          .where((r) => r.userId == _userId)
          .toList();

      // Отправляем каждую запись в Supabase
      for (final reflection in userReflections) {
        try {
          final data = reflection.toSupabaseMap();
          await _supabase
              .from('daily_reflections')
              .upsert(data, onConflict: 'id');
        } catch (e) {
          Log.e('Failed to sync reflection ${reflection.id}: $e');
        }
      }

      Log.i('Local data synced with Supabase for user: $_userId');
    } catch (e, stackTrace) {
      Log.e(
        'Error syncing local data with Supabase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
