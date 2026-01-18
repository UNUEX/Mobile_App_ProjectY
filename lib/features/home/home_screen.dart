// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import '../digital_twin/digital_twin_screen.dart';
import '../simulation/simulation_screen.dart';
import '../your_state/your_state_screen.dart';
// Импортируй экран AI Navigator, если он уже создан, или оставь пока без импорта
// import '../ai_navigator/ai_navigator_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Используем белый фон или очень светлый, чтобы карточки выделялись
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Logo / Title ---
                const Text(
                  "Yauctor.ai",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your personal navigation platform",
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),

                const SizedBox(height: 28),

                // --- Hero Card (Фиолетовая) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // Цвет фона карточки (Lavender / Light Purple)
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What if you had chosen a different path?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Explore without commitment. Understand without pressure.",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- Section title ---
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    "Explore Features",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),

                // --- Features list ---
                _FeatureTile(
                  icon: Icons.person_outline,
                  title: "Digital Twin",
                  subtitle:
                      "A reflection of your current state, patterns, and energy",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DigitalTwinScreen(),
                      ),
                    );
                  },
                ),
                _FeatureTile(
                  icon: Icons.trending_up,
                  title: "Life Simulation",
                  subtitle:
                      "Explore alternative paths and their possible outcomes",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimulationScreen(),
                      ),
                    );
                  },
                ),
                _FeatureTile(
                  icon: Icons.auto_awesome,
                  title: "Your State",
                  subtitle: "Understand where you are, without judgment",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YourStateScreen(),
                      ),
                    );
                  },
                ),
                _FeatureTile(
                  icon: Icons.chat_bubble_outline,
                  title: "AI Navigator",
                  subtitle: "Ask questions, get clarity, find direction",
                  onTap: () {
                    // Пока просто заглушка, так как файла экрана нет
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("AI Navigator coming soon!"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Container отвечает за внешний вид (тень, рамка, скругление)
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ), // Тонкая рамка
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // Очень легкая тень
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 2. Material нужен для отрисовки эффекта InkWell (волны) поверх фона
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20), // Ограничиваем волну краями
          onTap: onTap,
          // Настройка цвета волны при нажатии
          splashColor: const Color(0xFF9333EA).withValues(alpha: 0.1),
          highlightColor: const Color(0xFF9333EA).withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20), // Внутренний отступ
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Выравнивание по верху, если текст длинный
              children: [
                // Иконка в квадрате
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF3E8FF,
                    ), // Светло-фиолетовый фон иконки
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF9333EA), // Насыщенный фиолетовый
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Текстовая часть
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ), // Чуть опустить заголовок для выравнивания с иконкой
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Стрелочка справа
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                  ), // Выравнивание стрелки
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[300],
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
