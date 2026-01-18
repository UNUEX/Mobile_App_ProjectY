// lib/features/simulation/simulation_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  // Состояния: 0 - Главная, 1 - Настройка, 2 - Загрузка, 3 - Результаты
  int _viewIndex = 0;

  // Данные сценариев
  final List<Map<String, dynamic>> _scenarios = [
    {
      'title': 'Current Path',
      'subtitle': 'Continue with your current role and commitments',
      'load': 70,
      'interest': 75,
      'growth': 65,
      'color': Colors.blueGrey,
    },
    {
      'title': 'Reduce & Learn',
      'subtitle': 'Reduce workload by 30%, focus on skill development',
      'load': 45,
      'interest': 60,
      'growth': 85,
      'color': Colors.blue,
    },
    {
      'title': 'Leadership Track',
      'subtitle': 'Take on leadership role, increase responsibility',
      'load': 85,
      'interest': 90,
      'growth': 92,
      'color': Colors.purple,
    },
    {
      'title': 'Career Pivot',
      'subtitle': 'Transition to adjacent field, fresh start',
      'load': 60,
      'interest': 88,
      'growth': 95,
      'color': Colors.green,
    },
  ];

  int _selectedScenario = 0;
  String _selectedTimeframe = '3 months';
  final List<String> _timeframes = ['3 months', '6 months', '12 months'];
  final List<String> _priorities = [
    'Work-Life Balance',
    'Personal Growth',
    'Mental Wellbeing',
  ];
  final Set<int> _selectedPriorities = {
    0,
    2,
  }; // Work-Life Balance и Mental Wellbeing по умолчанию

  final Color _accentColor = const Color(0xFF8B5CF6);

  void _runSimulation() {
    setState(() => _viewIndex = 2);
    Timer(const Duration(seconds: 2), () {
      setState(() => _viewIndex = 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _viewIndex != 2 ? _buildAppBar() : null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () {
          if (_viewIndex > 0) {
            setState(() => _viewIndex = 0);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        _viewIndex == 3 ? "Simulation Results" : "Life Simulation",
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_viewIndex == 0)
          IconButton(
            icon: Icon(Icons.tune, color: _accentColor),
            onPressed: () => setState(() => _viewIndex = 1),
          ),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_viewIndex) {
      case 0:
        return _buildMainView();
      case 1:
        return _buildParametersView();
      case 2:
        return _buildLoadingView();
      case 3:
        return _buildResultsView();
      default:
        return _buildMainView();
    }
  }

  // --- 1. ГЛАВНЫЙ ЭКРАН (С выбором сценариев) ---
  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            "Life Simulation",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Explore possible pathways",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            "Configure parameters and run a simulation to see how different choices might unfold over time.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Быстрый предпросмотр (из второй картинки)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Preview",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Predicted Satisfaction",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "72%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Choose a Scenario",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _scenarios.length,
            itemBuilder: (context, index) {
              final scenario = _scenarios[index];
              bool isSelected = _selectedScenario == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accentColor.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _accentColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedScenario = index),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: scenario['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  scenario['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? _accentColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: _accentColor),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scenario['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildMetricBox("Load", "${scenario['load']}%"),
                              const SizedBox(width: 8),
                              _buildMetricBox(
                                "Interest",
                                "${scenario['interest']}%",
                              ),
                              const SizedBox(width: 8),
                              _buildMetricBox(
                                "Growth",
                                "${scenario['growth']}%",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Run Simulation",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. ЭКРАН НАСТРОЙКИ ПАРАМЕТРОВ ---
  Widget _buildParametersView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            "Simulation Parameters",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Timeframe
          const Text(
            "Timeframe",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _timeframes.map((timeframe) {
              bool isSelected = _selectedTimeframe == timeframe;
              return ChoiceChip(
                label: Text(timeframe),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTimeframe = timeframe);
                },
                selectedColor: _accentColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Priority Focus
          const Text(
            "Priority Focus",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Column(
            children: _priorities.asMap().entries.map((entry) {
              int index = entry.key;
              String priority = entry.value;
              bool isSelected = _selectedPriorities.contains(index);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accentColor.withValues(alpha: 0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _accentColor : Colors.transparent,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedPriorities.remove(index);
                        } else {
                          _selectedPriorities.add(index);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected ? _accentColor : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            priority,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? _accentColor : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Выбранный сценарий
          const Text(
            "Selected Scenario",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scenarios[_selectedScenario]['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _scenarios[_selectedScenario]['subtitle'] as String,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Кнопка запуска
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Run Simulation",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- 3. ЭКРАН ЗАГРУЗКИ ---
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              color: _accentColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Simulation Complete",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            "Your digital twin has modeled this scenario across $_selectedTimeframe",
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Here's what the data suggests.",
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- 4. ЭКРАН РЕЗУЛЬТАТОВ ---
  Widget _buildResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            "Simulation Results",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_scenarios[_selectedScenario]['title']} • $_selectedTimeframe",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Панель с основными метриками (из третьей картинки)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Overview",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text("Timeline", style: TextStyle(color: Colors.grey)),
                    Text("Insights", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 24),

                // Метрики
                _buildResultMetricRow("Energy Gain", "+23%", Colors.green),
                const SizedBox(height: 16),
                _buildResultMetricRow("Stress Reduction", "-42%", Colors.blue),
                const SizedBox(height: 16),
                _buildResultMetricRow("Growth Potential", "+85%", _accentColor),
                const SizedBox(height: 16),
                _buildResultMetricRow("Workload Change", "-30%", Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Информация о сценарии
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scenarios[_selectedScenario]['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Simulated over $_selectedTimeframe",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Divider(height: 24),

                _buildProjectedMetric(
                  "Overall Satisfaction",
                  "72%",
                  _accentColor,
                ),
                const SizedBox(height: 12),
                _buildProjectedMetric(
                  "Growth Potential",
                  "${_scenarios[_selectedScenario]['growth']}%",
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildProjectedMetric("Burnout Risk", "35%", Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Кнопки действий
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _viewIndex = 0),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: _accentColor),
                  ),
                  child: Text(
                    "Try Another",
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Здесь можно добавить обсуждение с ИИ
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Discuss with AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectedMetric(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
