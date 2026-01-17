// lib/state/simulation_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/simulation_result.dart';

// ✅ ПРАВИЛЬНЫЙ синтаксис для Riverpod 2.x
final simulationProvider =
    NotifierProvider<SimulationNotifier, SimulationResult?>(
      SimulationNotifier.new, // ← Используем .new
    );

class SimulationNotifier extends Notifier<SimulationResult?> {
  // Обязательный метод build()
  @override
  SimulationResult? build() {
    return null; // начальное значение
  }

  Future<void> runSimulation(String input) async {
    await Future.delayed(const Duration(seconds: 2));

    state = SimulationResult(
      input: input,
      recommendation: 'AI рекомендует оптимизировать стратегию для "$input"',
      createdAt: DateTime.now(),
    );
  }
}
