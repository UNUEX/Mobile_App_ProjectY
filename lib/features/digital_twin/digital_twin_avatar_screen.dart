// lib/features/digital_twin/digital_twin_avatar_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DigitalTwinAvatarScreen extends StatefulWidget {
  const DigitalTwinAvatarScreen({super.key});

  @override
  State<DigitalTwinAvatarScreen> createState() =>
      _DigitalTwinAvatarScreenState();
}

class _DigitalTwinAvatarScreenState extends State<DigitalTwinAvatarScreen>
    with SingleTickerProviderStateMixin {
  final Color _primaryPurple = const Color(0xFF8B5CF6);
  final Color _bgPurple = const Color(0xFFF3E8FF);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryPurple,
                  const Color(0xFF7C3AED),
                  const Color(0xFF6D28D9),
                ],
              ),
            ),
          ),

          // Floating particles effect
          ...List.generate(8, (index) => _buildFloatingParticle(index)),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        'Avatar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Avatar Section
                        _buildAvatarSection(),

                        const SizedBox(height: 40),

                        // Content Card
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),

                              // Tabs
                              _buildTabs(),

                              const SizedBox(height: 24),

                              // Tab Content
                              _buildTabContent(),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final left = random.nextDouble() * 300;
    final top = random.nextDouble() * 400;
    final size = 4.0 + random.nextDouble() * 8;

    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 2000 + random.nextInt(2000)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, math.sin(value * math.pi * 2) * 20),
            child: Opacity(
              opacity: 0.3 + math.sin(value * math.pi * 2) * 0.2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        onEnd: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Pulsing Avatar
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryPurple.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: _primaryPurple,
                          ),
                        ),

                        // Status indicator
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
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

        // Name
        const Text(
          'Alex Morgan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.psychology, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Active & Learning',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Stats Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('85%', 'Accuracy'),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildStatItem('127', 'Simulations'),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildStatItem('23d', 'Active'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            _buildTab('Overview', 0),
            _buildTab('Traits', 1),
            _buildTab('Insights', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildTraitsTab();
      case 2:
        return _buildInsightsTab();
      default:
        return Container();
    }
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Personality Snapshot
          _buildSectionCard(
            title: 'Personality Snapshot',
            icon: Icons.psychology,
            child: Column(
              children: [
                _buildPersonalityBar('Openness', 0.85, const Color(0xFF8B5CF6)),
                _buildPersonalityBar(
                  'Conscientiousness',
                  0.72,
                  const Color(0xFF3B82F6),
                ),
                _buildPersonalityBar(
                  'Extraversion',
                  0.45,
                  const Color(0xFFF59E0B),
                ),
                _buildPersonalityBar(
                  'Agreeableness',
                  0.88,
                  const Color(0xFF10B981),
                ),
                _buildPersonalityBar(
                  'Emotional Stability',
                  0.65,
                  const Color(0xFFEC4899),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Core Values
          _buildSectionCard(
            title: 'Core Values',
            icon: Icons.favorite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildValueChip('Growth', Icons.trending_up),
                _buildValueChip('Creativity', Icons.palette),
                _buildValueChip('Authenticity', Icons.verified),
                _buildValueChip('Impact', Icons.auto_awesome),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Activity
          _buildSectionCard(
            title: 'Recent Activity',
            icon: Icons.history,
            child: Column(
              children: [
                _buildActivityItem(
                  'Completed career simulation',
                  '2 hours ago',
                  Icons.work,
                  const Color(0xFF8B5CF6),
                ),
                _buildActivityItem(
                  'Updated life goals',
                  'Yesterday',
                  Icons.flag,
                  const Color(0xFF3B82F6),
                ),
                _buildActivityItem(
                  'Mood check-in completed',
                  '2 days ago',
                  Icons.emoji_emotions,
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Work Style',
            icon: Icons.work_outline,
            child: Column(
              children: [
                _buildTraitRow('Deep Work Focus', '85%', Icons.psychology),
                _buildTraitRow('Collaboration', '60%', Icons.people),
                _buildTraitRow('Flexibility', '72%', Icons.swap_horiz),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildSectionCard(
            title: 'Behavioral Patterns',
            icon: Icons.auto_graph,
            child: Column(
              children: [
                _buildPatternCard(
                  'Morning Person',
                  'Peak productivity: 7AM - 11AM',
                  Icons.wb_sunny,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                _buildPatternCard(
                  'Introvert Tendencies',
                  'Recharges through solitude',
                  Icons.self_improvement,
                  const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 12),
                _buildPatternCard(
                  'Detail-Oriented',
                  'High attention to accuracy',
                  Icons.zoom_in,
                  const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'AI Recommendations',
            icon: Icons.lightbulb,
            child: Column(
              children: [
                _buildInsightCard(
                  'Schedule deep work sessions in the morning',
                  'Based on your energy patterns',
                  Icons.schedule,
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                _buildInsightCard(
                  'Take breaks between meetings',
                  'Optimal for your personality type',
                  Icons.coffee,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                _buildInsightCard(
                  'Consider creative side projects',
                  'Aligns with your core values',
                  Icons.brush,
                  const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildSectionCard(
            title: 'Growth Areas',
            icon: Icons.trending_up,
            child: Column(
              children: [
                _buildGrowthItem('Public Speaking', 0.45),
                _buildGrowthItem('Delegation Skills', 0.58),
                _buildGrowthItem('Risk Taking', 0.52),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _bgPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalityBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _bgPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primaryPurple),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _primaryPurple,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _primaryPurple),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey[100],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
