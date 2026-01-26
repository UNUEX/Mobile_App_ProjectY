// lib/features/digital_twin/digital_twin_screen.dart
import 'package:flutter/material.dart';
import 'daily_checkin_screen.dart';

class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});

  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends State<DigitalTwinScreen> {
  // 0 = Intro, 1 = Age, 2 = Context, 3 = Values, 4 = Dashboard
  int _currentStep = 0;

  // Данные для хранения ответов
  String? _selectedAge;
  String? _selectedContext;
  final List<String> _selectedValues = [];

  // Основной фиолетовый цвет из дизайна
  final Color _accentColor = const Color(0xFF8B5CF6);

  void _nextStep() {
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
      }
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // В зависимости от шага показываем разный UI
    if (_currentStep == 0) return _buildIntroScreen();
    if (_currentStep == 4) return _buildDashboardScreen();
    return _buildQuizScreen();
  }

  // --- 1. INTRO SCREEN (Как на image_d5a00f.png) ---
  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Avatar',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mockup графика
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF), // Очень светлый фон
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.show_chart,
                                size: 16,
                                color: _accentColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Demo Visualization",
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildMockBar(
                            "Current Path",
                            0.7,
                            Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          _buildMockBar(
                            "Alternative A",
                            0.4,
                            const Color(0xFFA78BFA),
                          ),
                          const SizedBox(height: 16),
                          _buildMockBar("Alternative B", 0.85, _accentColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "A living model of your patterns, energy, and state. Not a diagnosis — a mirror that helps you see yourself more clearly.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "What this gives you",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _buildBulletPoint(
                      "Real-time understanding of your energy and stress",
                    ),
                    _buildBulletPoint("Pattern recognition without judgment"),
                    _buildBulletPoint(
                      "Context-aware insights based on your reality",
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
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
                    "Make this about me",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. QUIZ SCREEN (Шаги 1, 2, 3) ---
  Widget _buildQuizScreen() {
    // Определяем контент в зависимости от шага
    String title = "";
    String subtitle = "";
    Widget content = const SizedBox();

    if (_currentStep == 1) {
      title = "How old are you?";
      subtitle = "Helps us understand your context better";
      content = Column(
        children: ["18-24", "25-34", "35-44", "45-54", "55+"]
            .map(
              (age) => _buildSelectableOption(age, _selectedAge == age, () {
                setState(() => _selectedAge = age);
              }),
            )
            .toList(),
      );
    } else if (_currentStep == 2) {
      title = "What's your current context?";
      subtitle = "Where are you in life right now?";
      content = Column(
        children: ["Studying", "Working", "Between jobs", "Exploring", "Other"]
            .map(
              (ctx) => _buildSelectableOption(ctx, _selectedContext == ctx, () {
                setState(() => _selectedContext = ctx);
              }),
            )
            .toList(),
      );
    } else if (_currentStep == 3) {
      title = "What matters to you?";
      subtitle = "Pick as many as you like";
      content = Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          "Career Growth",
          "Learning",
          "Relationships",
          "Health",
          "Creativity",
          "Travel",
          "Finance",
          "Balance",
        ].map((val) => _buildChipOption(val)).toList(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _prevStep,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(_currentStep >= 1),
            _buildDot(_currentStep >= 2),
            _buildDot(_currentStep >= 3),
            _buildDot(_currentStep >= 4), // Placeholder
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _nextStep,
            child: const Text("Skip", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Everything is optional",
                      style: TextStyle(color: _accentColor, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    content,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. DASHBOARD SCREEN (Финальный результат, image_d5f2c0.png) ---
  Widget _buildDashboardScreen() {
    return Scaffold(
      backgroundColor: Colors
          .white, // Можно использовать серый 0xFFF9FAFB, но на скрине белый
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Sunday, January 11",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_none, size: 28),
                ],
              ),
              const SizedBox(height: 24),

              // Your State Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FF), // Light purple tint
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, color: _accentColor, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "Your State",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStatBar("Energy", 0.68, "68%"),
                    const SizedBox(height: 16),
                    _buildStatBar("Stress", 0.42, "42%"),
                    const SizedBox(height: 20),
                    Text(
                      "You're carrying moderate energy with manageable stress. Your pattern suggests you're in a sustainable state.",
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "View trends →",
                      style: TextStyle(
                        color: _accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Insight Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: _accentColor, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "AI Insight",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Your digital twin noticed you're most energized during morning hours. Consider protecting this time.",
                      style: TextStyle(color: Colors.grey[800], height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Why this matters: Your energy patterns show a 35% drop after lunch...",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Gentle Suggestion
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gentle Suggestion",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Consider a 5-minute pause before your next task.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Grid Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSmallActionCard(
                      Icons.trending_up,
                      "Life Simulation",
                      "Explore paths",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallActionCard(
                      Icons.chat_bubble_outline,
                      "AI Navigator",
                      "Ask questions",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 24),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // !!! ВОТ ЗДЕСЬ ИЗМЕНЕНИЕ !!!
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyCheckinScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Daily Check-in",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Keep your digital twin alive",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers & Reusable Widgets ---

  // Helper для построения баров в Intro
  Widget _buildMockBar(String label, double pct, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper для буллитов
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: _accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Helper для точек навигации в AppBar
  Widget _buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: active ? _accentColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // Опция выбора (Возраст, Контекст)
  Widget _buildSelectableOption(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _accentColor
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // Опция выбора "Chips" (Values)
  Widget _buildChipOption(String label) {
    final isSelected = _selectedValues.contains(label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedValues.remove(label);
          } else {
            _selectedValues.add(label);
          }
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? _accentColor
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _accentColor : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Бар статистики (Energy/Stress) для Dashboard
  Widget _buildStatBar(String label, double pct, String valueText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 14,
                color: _accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF), // Бледный фон
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Маленькая карточка внизу Dashboard
  Widget _buildSmallActionCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _accentColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
