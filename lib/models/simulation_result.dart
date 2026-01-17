// lib/models/simulation_result.dart
class SimulationResult {
  final String input;
  final String recommendation;
  final DateTime createdAt;

  SimulationResult({
    required this.input,
    required this.recommendation,
    required this.createdAt,
  });
}
