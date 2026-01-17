// lib/features/simulation/simulation_screen.dart
import 'package:flutter/material.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Simulation',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}
