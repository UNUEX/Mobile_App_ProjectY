// lib/features/journey/services/journey_container_repository.dart
// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journey_container.dart';
import '../../../core/utils/logger_service.dart';

class JourneyContainerRepository {
  final String userId;
  final SupabaseClient _supabase = Supabase.instance.client;

  JourneyContainerRepository({required this.userId});

  /// Создание нового контейнера
  Future<JourneyContainer> createContainer({
    required String name,
    String? description,
    String? coverColor,
  }) async {
    try {
      final container = JourneyContainer(
        userId: userId,
        name: name,
        description: description,
        coverColor: coverColor ?? _getRandomColor(),
      );

      final data = container.toJson();

      await _supabase.from('journey_containers').insert(data);

      Log.i('Journey container created: ${container.id}');
      return container;
    } catch (e, stackTrace) {
      Log.e('Error creating container', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Получение всех контейнеров пользователя
  Future<List<JourneyContainer>> getContainers() async {
    try {
      print('DEBUG: Fetching journey containers for user: $userId');

      final response = await _supabase
          .from('journey_containers')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final containers = <JourneyContainer>[];

      for (final item in response) {
        try {
          final container = JourneyContainer.fromJson(item);
          containers.add(container);
        } catch (e) {
          Log.e('Error parsing container: $e\nItem: $item');
        }
      }

      print('DEBUG: Found ${containers.length} journey containers');
      return containers;
    } catch (e, stackTrace) {
      Log.e('Error fetching containers', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Получение контейнера по ID
  Future<JourneyContainer?> getContainerById(String containerId) async {
    try {
      final response = await _supabase
          .from('journey_containers')
          .select()
          .eq('user_id', userId)
          .eq('id', containerId)
          .maybeSingle();

      if (response != null) {
        return JourneyContainer.fromJson(response);
      }
      return null;
    } catch (e, stackTrace) {
      Log.e('Error fetching container by ID', error: e, stackTrace: stackTrace);
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
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (coverColor != null) updates['cover_color'] = coverColor;

      await _supabase
          .from('journey_containers')
          .update(updates)
          .eq('user_id', userId)
          .eq('id', containerId);

      Log.i('Container updated: $containerId');
    } catch (e, stackTrace) {
      Log.e('Error updating container', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Обновление количества симуляций в контейнере
  Future<void> updateSimulationCount(String containerId, int count) async {
    try {
      await _supabase
          .from('journey_containers')
          .update({
            'simulation_count': count,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('id', containerId);

      Log.i('Container simulation count updated: $containerId -> $count');
    } catch (e, stackTrace) {
      Log.e(
        'Error updating simulation count',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Удаление контейнера
  Future<void> deleteContainer(String containerId) async {
    try {
      await _supabase
          .from('journey_containers')
          .delete()
          .eq('user_id', userId)
          .eq('id', containerId);

      Log.i('Container deleted: $containerId');
    } catch (e, stackTrace) {
      Log.e('Error deleting container', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Удаление всех контейнеров пользователя
  Future<void> deleteAllContainers() async {
    try {
      await _supabase.from('journey_containers').delete().eq('user_id', userId);
      Log.i('All containers deleted for user: $userId');
    } catch (e, stackTrace) {
      Log.e('Error deleting all containers', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Проверка существования контейнера
  Future<bool> containerExists(String containerId) async {
    try {
      final response = await _supabase
          .from('journey_containers')
          .select('id')
          .eq('user_id', userId)
          .eq('id', containerId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      Log.e(
        'Error checking if container exists',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Получение случайного цвета для карточки
  String _getRandomColor() {
    final colors = [
      '#3B82F6', // Blue
      '#8B5CF6', // Purple
      '#EC4899', // Pink
      '#F59E0B', // Amber
      '#10B981', // Emerald
      '#06B6D4', // Cyan
      '#F97316', // Orange
      '#6366F1', // Indigo
    ];
    colors.shuffle();
    return colors.first;
  }
}
