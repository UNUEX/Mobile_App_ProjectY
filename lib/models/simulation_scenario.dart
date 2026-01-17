// lib/models/simulation_scenario.dart
import 'package:flutter/material.dart';

class SimulationScenario {
  final String id;
  final String title;
  final String description;
  final String category;
  final Map<String, double> baseMetrics;
  final int color;
  final IconData icon;

  SimulationScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.baseMetrics,
    required this.color,
    required this.icon,
  });

  Color get colorValue => Color(color);
}
