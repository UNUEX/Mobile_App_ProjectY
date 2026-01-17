// lib/models/simulation_result.dart
class SimulationResult {
  final String id;
  final String scenarioTitle;
  final String input;
  final String recommendation;
  final Map<String, double> metrics;
  final DateTime createdAt;
  final String category;
  final String? scenarioId;
  final String? customNote;
  final Map<String, double>? customModifiers;

  SimulationResult({
    String? id,
    required this.scenarioTitle,
    required this.input,
    required this.recommendation,
    required this.metrics,
    required this.category,
    required this.createdAt,
    this.scenarioId,
    this.customNote,
    this.customModifiers,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scenarioTitle': scenarioTitle,
      'input': input,
      'recommendation': recommendation,
      'metrics': metrics,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'scenarioId': scenarioId,
      'customNote': customNote,
      'customModifiers': customModifiers,
    };
  }

  static SimulationResult fromMap(Map<String, dynamic> map) {
    return SimulationResult(
      id: map['id'],
      scenarioTitle: map['scenarioTitle'],
      input: map['input'],
      recommendation: map['recommendation'],
      metrics: Map<String, double>.from(map['metrics']),
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      scenarioId: map['scenarioId'],
      customNote: map['customNote'],
      customModifiers: map['customModifiers'] != null
          ? Map<String, double>.from(map['customModifiers'])
          : null,
    );
  }
}
