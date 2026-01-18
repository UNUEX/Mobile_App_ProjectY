// lib/features/digital_twin/daily_checkin_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  // Текущий шаг: 0 = Energy, 1 = Clarity, 2 = Feeling, 3 = Success
  int _currentStep = 0;

  // Данные состояния
  double _energyValue = 0.5;
  double _clarityValue = 0.5;
  String? _selectedFeeling;

  final Color _accentColor = const Color(0xFF8B5CF6);

  // Переход к следующему шагу
  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      }
    });

    // Если это экран успеха (шаг 3), запускаем таймер на закрытие
    if (_currentStep == 3) {
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context); // Возвращаемся назад
        }
      });
    }
  }

  // Логика смайликов в зависимости от значения слайдера
  String _getEmoji(double value) {
    if (value < 0.2) return "😫"; // Drained / Foggy
    if (value < 0.4) return "😕";
    if (value < 0.6) return "😐"; // Neutral
    if (value < 0.8) return "🙂";
    return "🤩"; // Energized / Clear
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _currentStep == 3 ? _buildSuccessView() : _buildQuestionFlow(),
        ),
      ),
    );
  }

  Widget _buildQuestionFlow() {
    return Column(
      children: [
        // Header: Close button + Progress Bars
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 24, color: Colors.black54),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Spacer(),
            // Progress Indicators
            Row(
              children: [
                _buildProgressDash(0),
                const SizedBox(width: 8),
                _buildProgressDash(1),
                const SizedBox(width: 8),
                _buildProgressDash(2),
              ],
            ),
            const Spacer(),
            const SizedBox(width: 24), // Invisible spacer to center progress
          ],
        ),

        const SizedBox(height: 40),

        // Dynamic Title & Content
        Text(
          "Daily Check-in",
          style: TextStyle(color: _accentColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          "Takes under 10 seconds",
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),

        const SizedBox(height: 32),

        Expanded(child: _buildStepContent()),

        // Bottom Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSliderStep(
          title: "How's your energy right now?",
          subtitle: "Just in this moment",
          leftLabel: "Drained",
          rightLabel: "Energized",
          value: _energyValue,
          onChanged: (val) => setState(() => _energyValue = val),
        );
      case 1:
        return _buildSliderStep(
          title: "How clear is your mind?",
          subtitle: "No judgment, just noticing",
          leftLabel: "Foggy",
          rightLabel: "Clear",
          value: _clarityValue,
          onChanged: (val) => setState(() => _clarityValue = val),
        );
      case 2:
        return _buildSelectionStep();
      default:
        return const SizedBox();
    }
  }

  // --- Шаблон для слайдеров (Шаг 1 и 2) ---
  Widget _buildSliderStep({
    required String title,
    required String subtitle,
    required String leftLabel,
    required String rightLabel,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const SizedBox(height: 48),

        // Custom Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 12,
            activeTrackColor: _accentColor,
            inactiveTrackColor: Colors.grey[200],
            thumbColor: _accentColor.withValues(
              alpha: 0.5,
            ), // Полупрозрачный ореол
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftLabel, style: TextStyle(color: Colors.grey[400])),
            Text(rightLabel, style: TextStyle(color: Colors.grey[400])),
          ],
        ),

        const SizedBox(height: 40),

        // Emoji Box
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF), // Очень светлый фиолетовый
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(_getEmoji(value), style: const TextStyle(fontSize: 64)),
          ),
        ),
      ],
    );
  }

  // --- Шаблон для выбора (Шаг 3) ---
  Widget _buildSelectionStep() {
    final options = ["Light", "Balanced", "Heavy", "Uncertain"];

    return Column(
      children: [
        const Text(
          "How does today feel?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Trust your intuition",
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
        const SizedBox(height: 32),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedFeeling = option),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFeeling == option
                        ? _accentColor
                        : Colors.grey.withValues(alpha: 0.2),
                    width: _selectedFeeling == option ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedFeeling == option
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Финальный экран успеха ---
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF9F7AEA), // Slightly lighter purple
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 32),
        const Text(
          "Thank you",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          "Your digital twin is learning",
          style: TextStyle(fontSize: 18, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // Индикатор прогресса (черточки сверху)
  Widget _buildProgressDash(int stepIndex) {
    bool isActive = _currentStep >= stepIndex;
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? _accentColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
