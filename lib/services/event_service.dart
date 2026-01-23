// lib/services/event_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/home/models/event_model.dart';

class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<EventModel>> getEventsForMonth(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final response = await _supabase
        .from('events')
        .select()
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: true);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  Future<EventModel> createEvent(EventModel event) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('events')
        .insert({
          'user_id': user.id,
          'date': event.date.toIso8601String(),
          'title': event.title,
          'description': event.description,
          'location': event.location,
          'start_time': event.startTime?.toIso8601String(),
          'end_time': event.endTime?.toIso8601String(),
          'has_notification': event.hasNotification,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return EventModel.fromJson(response);
  }

  Future<EventModel> updateEvent(EventModel event) async {
    final response = await _supabase
        .from('events')
        .update({
          'title': event.title,
          'description': event.description,
          'location': event.location,
          'start_time': event.startTime?.toIso8601String(),
          'end_time': event.endTime?.toIso8601String(),
          'has_notification': event.hasNotification,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', event.id)
        .select()
        .single();

    return EventModel.fromJson(response);
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('events').delete().eq('id', id);
  }
}
