// lib/features/journey/models/journey_container.dart
import 'package:uuid/uuid.dart';

/// Контейнер для группы веток - представляет отдельную "карточку" на главном экране
class JourneyContainer {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int simulationCount;
  final String? coverColor; // Для визуального различия карточек

  JourneyContainer({
    String? id,
    required this.userId,
    required this.name,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.simulationCount = 0,
    this.coverColor,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory JourneyContainer.fromJson(Map<String, dynamic> json) {
    return JourneyContainer(
      id: json['id']?.toString() ?? const Uuid().v4(),
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Journey',
      description: json['description']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      simulationCount: (json['simulation_count'] is num)
          ? (json['simulation_count'] as num).toInt()
          : 0,
      coverColor: json['cover_color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'simulation_count': simulationCount,
      'cover_color': coverColor,
    };
  }

  JourneyContainer copyWith({
    String? name,
    String? description,
    DateTime? updatedAt,
    int? simulationCount,
    String? coverColor,
  }) {
    return JourneyContainer(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      simulationCount: simulationCount ?? this.simulationCount,
      coverColor: coverColor ?? this.coverColor,
    );
  }
}
