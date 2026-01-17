// lib/state/simulation_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/simulation_result.dart';
import '../models/simulation_scenario.dart';

final simulationsProvider =
    NotifierProvider<SimulationsNotifier, List<SimulationResult>>(
      SimulationsNotifier.new,
    );

final scenariosProvider = Provider<List<SimulationScenario>>((ref) {
  return [
    SimulationScenario(
      id: 'current_path',
      title: 'Current Path',
      description: 'Continue with your current work and responsibilities.',
      category: 'work',
      baseMetrics: {
        'workload': 0.7,
        'interest': 0.6,
        'stress': 0.5,
        'growth': 0.4,
        'income': 0.8,
      },
      color: 0xFF667EEA,
      icon: Icons.trending_flat,
    ),
    SimulationScenario(
      id: 'career_shift',
      title: 'Career Shift',
      description: 'Transition to a new field or industry.',
      category: 'career',
      baseMetrics: {
        'workload': 0.8,
        'interest': 0.9,
        'stress': 0.7,
        'growth': 0.9,
        'income': 0.5,
      },
      color: 0xFF10B981,
      icon: Icons.trending_up,
    ),
    SimulationScenario(
      id: 'work_life_balance',
      title: 'Work-Life Balance',
      description: 'Reduce hours and focus on wellbeing.',
      category: 'lifestyle',
      baseMetrics: {
        'workload': 0.4,
        'interest': 0.5,
        'stress': 0.2,
        'growth': 0.3,
        'income': 0.6,
      },
      color: 0xFF8B5CF6,
      icon: Icons.self_improvement,
    ),
    SimulationScenario(
      id: 'entrepreneur',
      title: 'Entrepreneurship',
      description: 'Start your own business or project.',
      category: 'business',
      baseMetrics: {
        'workload': 0.9,
        'interest': 0.95,
        'stress': 0.85,
        'growth': 0.95,
        'income': 0.3,
      },
      color: 0xFFF59E0B,
      icon: Icons.business,
    ),
    SimulationScenario(
      id: 'education',
      title: 'Further Education',
      description: 'Pursue additional degrees or certifications.',
      category: 'education',
      baseMetrics: {
        'workload': 0.6,
        'interest': 0.7,
        'stress': 0.6,
        'growth': 0.8,
        'income': 0.4,
      },
      color: 0xFFEC4899,
      icon: Icons.school,
    ),
  ];
});

final latestSimulationProvider = Provider<SimulationResult?>((ref) {
  final simulations = ref.watch(simulationsProvider);
  return simulations.isNotEmpty ? simulations.last : null;
});

final simulationStatsProvider = Provider<SimulationStats>((ref) {
  final simulations = ref.watch(simulationsProvider);

  if (simulations.isEmpty) {
    return SimulationStats.empty();
  }

  final avgInterest =
      simulations
          .map((s) => s.metrics['interest'] ?? 0)
          .reduce((a, b) => a + b) /
      simulations.length;

  final avgWorkload =
      simulations
          .map((s) => s.metrics['workload'] ?? 0)
          .reduce((a, b) => a + b) /
      simulations.length;

  final categories = simulations.map((s) => s.category).toSet();

  final categoryCounts = <String, int>{};
  for (final sim in simulations) {
    categoryCounts[sim.category] = (categoryCounts[sim.category] ?? 0) + 1;
  }

  return SimulationStats(
    total: simulations.length,
    avgInterest: avgInterest,
    avgWorkload: avgWorkload,
    categories: categories.length,
    categoryDistribution: categoryCounts,
    recentCount: simulations.length > 3 ? 3 : simulations.length,
  );
});

class SimulationsNotifier extends Notifier<List<SimulationResult>> {
  @override
  List<SimulationResult> build() {
    return [];
  }

  void addCustomSimulation({
    required String scenarioId,
    required String title,
    Map<String, double>? customMetrics,
    String? customNote,
    double workloadModifier = 0.0,
    double interestModifier = 0.0,
    double stressModifier = 0.0,
  }) {
    final scenarios = ref.read(scenariosProvider);
    final scenario = scenarios.firstWhere(
      (s) => s.id == scenarioId,
      orElse: () => scenarios.first,
    );

    final adjustedMetrics = Map<String, double>.from(scenario.baseMetrics);
    adjustedMetrics['workload'] =
        (adjustedMetrics['workload']! + workloadModifier).clamp(0.0, 1.0);
    adjustedMetrics['interest'] =
        (adjustedMetrics['interest']! + interestModifier).clamp(0.0, 1.0);
    adjustedMetrics['stress'] = (adjustedMetrics['stress']! + stressModifier)
        .clamp(0.0, 1.0);

    final overallScore =
        (adjustedMetrics['interest']! * 0.4 +
        (1 - adjustedMetrics['stress']!) * 0.3 +
        (1 - adjustedMetrics['workload']!) * 0.2 +
        adjustedMetrics['growth']! * 0.1);

    if (customMetrics != null) {
      adjustedMetrics.addAll(customMetrics);
    }
    adjustedMetrics['overallScore'] = overallScore;

    final customModifiers = {
      'workloadModifier': workloadModifier,
      'interestModifier': interestModifier,
      'stressModifier': stressModifier,
    };

    final result = SimulationResult(
      scenarioTitle: title,
      input: customNote ?? "Custom simulation of $title",
      recommendation: _generateRecommendation(
        adjustedMetrics,
        scenario.category,
      ),
      metrics: adjustedMetrics,
      category: scenario.category,
      createdAt: DateTime.now(),
      scenarioId: scenarioId,
      customNote: customNote,
      customModifiers: customModifiers,
    );

    state = [...state, result];
  }

  void addSimulation(SimulationResult simulation) {
    state = [...state, simulation];
  }

  List<SimulationResult> getByCategory(String category) {
    return state.where((s) => s.category == category).toList();
  }

  List<SimulationResult> getByDateRange(DateTime start, DateTime end) {
    return state
        .where((s) => s.createdAt.isAfter(start) && s.createdAt.isBefore(end))
        .toList();
  }

  List<SimulationResult> getTopSimulations({int limit = 5}) {
    return List.from(state)
      ..sort(
        (a, b) => (b.metrics['overallScore'] ?? 0).compareTo(
          a.metrics['overallScore'] ?? 0,
        ),
      )
      ..take(limit);
  }

  void deleteSimulation(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void clearHistory() {
    state = [];
  }

  String _generateRecommendation(Map<String, double> metrics, String category) {
    final overall = metrics['overallScore'] ?? 0;
    final stress = metrics['stress'] ?? 0;
    final interest = metrics['interest'] ?? 0;

    if (overall > 0.8) {
      return "Excellent choice! This path aligns well with your goals and has high fulfillment potential.";
    } else if (overall > 0.6) {
      if (stress > 0.7) {
        return "Good potential but consider stress management strategies for sustainability.";
      }
      return "Solid option with good balance. Consider minor adjustments for optimal results.";
    } else {
      if (interest < 0.3) {
        return "Low interest detected. Explore alternative options that better match your passions.";
      }
      return "This path has challenges. Consider exploring other options or adjusting parameters.";
    }
  }
}

class SimulationStats {
  final int total;
  final double avgInterest;
  final double avgWorkload;
  final int categories;
  final Map<String, int> categoryDistribution;
  final int recentCount;

  SimulationStats({
    required this.total,
    required this.avgInterest,
    required this.avgWorkload,
    required this.categories,
    required this.categoryDistribution,
    required this.recentCount,
  });

  factory SimulationStats.empty() {
    return SimulationStats(
      total: 0,
      avgInterest: 0,
      avgWorkload: 0,
      categories: 0,
      categoryDistribution: {},
      recentCount: 0,
    );
  }
}
