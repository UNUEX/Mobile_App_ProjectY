// lib/features/home/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Palette
  final Color _bgLight = const Color(0xFFF8F9FC);
  final Color _primaryPurple = const Color(0xFF7C3AED);
  final Color _primaryDark = const Color(0xFF1E1B4B);

  // Predefined colors with transparency for performance
  final Color _blackWithTransparency10 = Color.fromRGBO(0, 0, 0, 0.1);
  final Color _blackWithTransparency70 = Color.fromRGBO(0, 0, 0, 0.7);
  final Color _whiteWithTransparency20 = Color.fromRGBO(255, 255, 255, 0.2);
  final Color _whiteWithTransparency80 = Color.fromRGBO(255, 255, 255, 0.8);
  final Color _greyWithTransparency05 = Color.fromRGBO(128, 128, 128, 0.05);
  final Color _greyWithTransparency10 = Color.fromRGBO(128, 128, 128, 0.1);
  final Color _whiteWithTransparency15 = Color.fromRGBO(255, 255, 255, 0.15);

  // Data
  final String _todayFocus = "Deep Work: Project X";
  final String _focusDescription = "Finish the architecture diagram";

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: _bgLight,
      body: Stack(
        children: [
          // 1. Ambient Background
          Positioned(
            top: -100,
            right: -100,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryPurple.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCalendarStrip(),
                  const SizedBox(height: 24),
                  _buildDailyReflectionCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Today's Focus"),
                  const SizedBox(height: 12),
                  _buildFocusCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Explore Reality"),
                  const SizedBox(height: 12),
                  _buildBentoGrid(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning,",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Alem",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _primaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        _buildAvatar(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: _blackWithTransparency10,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundImage: const NetworkImage(
          "https://ui-avatars.com/api/?name=Alex&background=7C3AED&color=fff",
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Timeline",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
              ),
            ),
            GestureDetector(
              onTap: () => _openFullCalendar(context),
              child: Text(
                "Open Calendar",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primaryPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isToday = index == 0;
              return _buildDateCard(date, isToday);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(DateTime date, bool isToday) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: isToday ? _primaryDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: _primaryDark.withAlpha(76), // 0.3 opacity ~ 76 alpha
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: _greyWithTransparency05,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
        border: isToday ? null : Border.all(color: _greyWithTransparency10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getWeekday(date),
            style: TextStyle(
              color: isToday ? Colors.white70 : Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${date.day}",
            style: TextStyle(
              color: isToday ? Colors.white : _primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isToday) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyReflectionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DailyReflectionScreen(),
          ),
        );
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: const DecorationImage(
            image: NetworkImage(
              "https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1000&auto=format&fit=crop",
            ),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: _blackWithTransparency10,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, _blackWithTransparency70],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _whiteWithTransparency20,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _whiteWithTransparency20),
                      ),
                      child: const Text(
                        "Daily Reflection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Train your Avatar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Record today's thoughts & emotions",
                      style: TextStyle(
                        color: _whiteWithTransparency80,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: _whiteWithTransparency20,
                  child: const Icon(
                    Icons.arrow_outward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _greyWithTransparency10),
        boxShadow: [
          BoxShadow(
            color: _greyWithTransparency05,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Color(0xFF3B82F6),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _todayFocus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryDark,
                  ),
                ),
                Text(
                  _focusDescription,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showFocusCompletedDialog,
            icon: const Icon(Icons.check_circle_outline_rounded),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  // --- Bento Grid Layout (FIXED) ---
  Widget _buildBentoGrid(BuildContext context) {
    const double totalHeight = 200;
    const double gap = 12;
    const double smallCardHeight = (totalHeight - gap) / 2;

    return Column(
      children: [
        Row(
          children: [
            // Big Card
            Expanded(
              flex: 3,
              child: _buildBentoCard(
                title: "Avatar",
                subtitle: "Analysis",
                icon: Icons.fingerprint,
                color1: const Color(0xFF6366F1),
                color2: const Color(0xFF8B5CF6),
                height: totalHeight,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DigitalTwinScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Column
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildBentoCard(
                    title: "State",
                    subtitle: "Energy",
                    icon: Icons.bolt_rounded,
                    color1: const Color(0xFFEC4899),
                    color2: const Color(0xFFF43F5E),
                    height: smallCardHeight, // Fixed Height
                    isSmall: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const YourStateScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBentoCard(
                    title: "Simulate",
                    subtitle: "Life Paths",
                    icon: Icons.route_outlined,
                    color1: const Color(0xFFF59E0B),
                    color2: const Color(0xFFD97706),
                    height: smallCardHeight, // Fixed Height
                    isSmall: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SimulationScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMemoryCard(),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required double height,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
          boxShadow: [
            BoxShadow(
              color: color1.withAlpha(76), // 0.3 opacity
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _whiteWithTransparency15,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmall ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _whiteWithTransparency20,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmall ? 20 : 24,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 15 : 18,
                        ),
                      ),
                      if (!isSmall)
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: _whiteWithTransparency80,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_edu, color: Color(0xFFD97706)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Memory from the Past",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  "Review what happened 1 year ago",
                  style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.amber[800],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _primaryDark,
        letterSpacing: -0.5,
      ),
    );
  }

  // --- Logic Helpers ---

  void _openFullCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScheduleScreen()),
    );
  }

  void _showFocusCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Mark as Done?"),
        content: const Text("This will update your productivity stats."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Complete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
