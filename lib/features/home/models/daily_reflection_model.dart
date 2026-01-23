// lib/features/home/models/daily_reflection_model.dart
import 'package:intl/intl.dart';

class DailyReflectionModel {
  final String id;
  final String text;
  final DateTime date;
  final String? emotion; // опционально: эмоция
  final Map<String, dynamic>? metadata; // дополнительные данные

  DailyReflectionModel({
    required this.id,
    required this.text,
    required this.date,
    this.emotion,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'date': date.toIso8601String(),
    'emotion': emotion,
    'metadata': metadata,
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
    );
  }

  // Для совместимости со старым форматом
  Map<String, String> toLegacyFormat() {
    return {'date': DateFormat('yyyy-MM-dd').format(date), 'text': text};
  }

  static DailyReflectionModel fromLegacyFormat(Map<String, String> legacy) {
    return DailyReflectionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: legacy['text']!,
      date: DateFormat('yyyy-MM-dd').parse(legacy['date']!),
    );
  }
}
