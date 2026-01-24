// lib/features/home/models/daily_reflection_model.dart
import 'package:intl/intl.dart';

class DailyReflectionModel {
  final String id;
  final String text;
  final DateTime date;
  final String? emotion; // опционально: эмоция
  final Map<String, dynamic>? metadata; // дополнительные данные
  final String userId; // ID пользователя для Supabase

  DailyReflectionModel({
    required this.id,
    required this.text,
    required this.date,
    this.emotion,
    this.metadata,
    required this.userId, // Обязательное поле для Supabase
  });

  // Для сохранения в SharedPreferences (совместимость)
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'date': date.toIso8601String(),
    'emotion': emotion,
    'metadata': metadata,
    'user_id': userId,
  };

  factory DailyReflectionModel.fromJson(Map<String, dynamic> json) {
    return DailyReflectionModel(
      id: json['id'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      emotion: json['emotion'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      userId: json['user_id'] ?? '', // Для совместимости со старыми данными
    );
  }

  // Для Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'metadata': metadata,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  factory DailyReflectionModel.fromSupabase(Map<String, dynamic> data) {
    return DailyReflectionModel(
      id: data['id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      text: data['text'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      emotion: data['emotion'],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  // Для совместимости со старым форматом
  Map<String, String> toLegacyFormat() {
    return {'date': DateFormat('yyyy-MM-dd').format(date), 'text': text};
  }

  static DailyReflectionModel fromLegacyFormat(
    Map<String, String> legacy,
    String userId,
  ) {
    return DailyReflectionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: legacy['text']!,
      date: DateFormat('yyyy-MM-dd').parse(legacy['date']!),
      userId: userId,
    );
  }

  // Для отладки
  @override
  String toString() {
    return 'DailyReflectionModel(id: $id, text: ${text.substring(0, text.length > 30 ? 30 : text.length)}..., userId: $userId)';
  }
}
