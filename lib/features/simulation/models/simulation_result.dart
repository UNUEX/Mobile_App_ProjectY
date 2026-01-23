// lib/features/simulation/models/simulation_result.dart
// Убрал Hive для упрощения
class SimulationResult {
  final String id;
  final String scenarioTitle;
  final DateTime createdAt;
  final Map<String, double> metrics;
  final String recommendation;
  final String? description;

  SimulationResult({
    required this.id,
    required this.scenarioTitle,
    required this.createdAt,
    required this.metrics,
    required this.recommendation,
    this.description,
  });

  // Метод toJson для сериализации
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenarioTitle': scenarioTitle,
      'createdAt': createdAt.toIso8601String(),
      'metrics': metrics,
      'recommendation': recommendation,
      'description': description,
    };
  }

  // Фабричный метод из JSON
  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      scenarioTitle: json['scenarioTitle'] ?? 'Без названия',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      metrics: Map<String, double>.from(json['metrics'] ?? {}),
      recommendation: json['recommendation'] ?? '',
      description: json['description'],
    );
  }
}
