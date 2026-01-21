// lib/features/home/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'calendar_schedule_screen.dart';
import '../digital_twin/digital_twin_screen.dart';
import '../simulation/simulation_screen.dart';
import '../your_state/your_state_screen.dart';
import 'daily_reflection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Цветовая палитра
  final Color _accentColor = const Color(0xFF8B5CF6); // Основной фиолетовый
  final Color _lightBg = const Color(0xFFF5F3FF); // Светлый фон
  final Color _darkText = const Color(0xFF1F1F29);

  bool _isFeaturesExpanded = false;

  // Пример фокуса дня
  final String _todayFocus = "Complete project documentation";
  final String _focusDescription = "Set aside 2 hours for focused work";

  // Пример воспоминания из прошлого
  final String _memoryTitle = "This day last year";
  final String _memoryContent =
      "You were preparing for your final exams. Remember how focused you were?";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER (Приветствие + Аватар)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning,",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Alex",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: _lightBg,
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://ui-avatars.com/api/?name=Alex&background=8B5CF6&color=fff",
                          ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withAlpha(128),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 2. CALENDAR STRIP (Мини-версия) -> Открывает полный календарь
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Timeline",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        color: _accentColor,
                      ),
                      onPressed: () => _openFullCalendar(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openFullCalendar(context),
                  child: SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 7,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        // Фейковая генерация дат
                        final date = DateTime.now().add(Duration(days: index));
                        final isToday = index == 0;

                        return Container(
                          width: 65,
                          decoration: BoxDecoration(
                            color: isToday ? _accentColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isToday
                                  ? _accentColor
                                  : Colors.grey.withAlpha(100),
                            ),
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: _accentColor.withAlpha(100),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getWeekday(date),
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white70
                                      : Colors.grey[400],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${date.day}",
                                style: TextStyle(
                                  color: isToday ? Colors.white : _darkText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 3. DIARY / JOURNAL WIDGET (Стеклянная карточка) - ИСПРАВЛЕНО
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyReflectionScreen(),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 140, // Фиксированная высота
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: const DecorationImage(
                              // ИСПРАВЛЕННЫЙ URL - рабочее изображение с Unsplash
                              image: NetworkImage(
                                "https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1000&auto=format&fit=crop",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Glass Overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: _accentColor.withAlpha(85),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Daily Reflection",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit_note,
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        "Record your thoughts to train your Digital Twin.",
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(200),
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withAlpha(80),
                                        ),
                                      ),
                                      child: const Text(
                                        "Write Entry",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. TODAY'S FOCUS / ФОКУС ДНЯ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Today's Focus",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0C4A6E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _todayFocus,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _focusDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B).withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Действие при нажатии "Mark as Done"
                                _showFocusCompletedDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0EA5E9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Mark as Done",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              // Редактировать фокус
                              _editTodayFocus();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. MEMORY FROM THE PAST / ВОСПОМИНАНИЕ ИЗ ПРОШЛОГО
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFEF3C7),
                        const Color(0xFFFDE68A),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withAlpha(60),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.history_edu_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Memory from the Past",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                // Показать следующее воспоминание
                                _showNextMemory();
                              },
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _memoryTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _memoryContent,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF78350F),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "March 15, 2023",
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF92400E).withAlpha(200),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Открыть подробности воспоминания
                                _openMemoryDetails();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFD97706),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "View Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 6. EXPLORE FEATURES (Сворачиваемый виджет)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFeaturesExpanded = !_isFeaturesExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.withAlpha(25)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withAlpha(13),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header карточки
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _lightBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.dashboard_customize_rounded,
                                  color: _accentColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "System Modules",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _darkText,
                                    ),
                                  ),
                                  Text(
                                    _isFeaturesExpanded
                                        ? "Tap to collapse"
                                        : "Tap to explore tools",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              AnimatedRotation(
                                turns: _isFeaturesExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 400),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Раскрывающаяся часть
                        AnimatedCrossFade(
                          firstChild: const SizedBox(
                            height: 0,
                            width: double.infinity,
                          ),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              children: [
                                _buildFeatureRow(
                                  icon: Icons.fingerprint,
                                  title: "Digital Twin",
                                  desc: "Analyze patterns",
                                  color: Colors.blueAccent,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DigitalTwinScreen(),
                                    ),
                                  ),
                                ),
                                _buildFeatureRow(
                                  icon: Icons.route,
                                  title: "Life Simulation",
                                  desc: "Alternative paths",
                                  color: Colors.orangeAccent,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SimulationScreen(),
                                    ),
                                  ),
                                ),
                                _buildFeatureRow(
                                  icon: Icons.psychology,
                                  title: "Your State",
                                  desc: "Mental energy",
                                  color: Colors.pinkAccent,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const YourStateScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          crossFadeState: _isFeaturesExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Навигация на новый экран календаря
  void _openFullCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScheduleScreen()),
    );
  }

  // Вспомогательные методы для новых виджетов
  void _showFocusCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Focus Completed!"),
        content: const Text(
          "Great job completing today's focus task. Want to set a new one?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editTodayFocus();
            },
            child: const Text("Set New Focus"),
          ),
        ],
      ),
    );
  }

  void _editTodayFocus() {
    // Здесь будет логика редактирования фокуса
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Edit focus functionality will be implemented soon"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNextMemory() {
    // Здесь будет логика показа следующего воспоминания
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Loading next memory..."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openMemoryDetails() {
    // Здесь будет навигация к деталям воспоминания
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Memory details will be shown here"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
