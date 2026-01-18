// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Не забудь добавить этот пакет

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Переменные состояния
  String _userName = "Traveler"; // Имя по умолчанию, пока грузится
  double energyLevel = 0.68;
  double stressLevel = 0.42;

  // Цвета (как в других экранах)
  final Color _accentColor = const Color(0xFF8B5CF6);
  final Color _lightAccentColor = const Color(0xFFF3E8FF);

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Загрузка имени из памяти
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Если имя не найдено, останется "Traveler"
      _userName = prefs.getString('userName') ?? "Traveler";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- 1. AVATAR & NAME ---
            _buildProfileHeader(),

            const SizedBox(height: 32),

            // --- 2. STATS (Как в Digital Twin) ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Energy",
                    "${(energyLevel * 100).toInt()}%",
                    energyLevel,
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "Stress",
                    "${(stressLevel * 100).toInt()}%",
                    stressLevel,
                    false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- 3. MENU ITEMS ---
            // Заголовок секции
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Settings & Preferences",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildMenuTile(
              icon: Icons.person_outline,
              title: "Personal Data",
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.shield_outlined,
              title: "Privacy & Security",
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.history,
              title: "Simulation History",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Log Out Button
            TextButton(
              onPressed: () {
                // Логика выхода
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Виджет шапки профиля
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _lightAccentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : "T",
                  style: TextStyle(
                    fontSize: 40,
                    color: _accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Explorer Mode", // Можно менять статус
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // Карточка статистики (Energy / Stress)
  Widget _buildStatCard(
    String title,
    String value,
    double percent,
    bool isEnergy,
  ) {
    // Для энергии используем фиолетовый, для стресса - можно другой оттенок или тот же
    final color = isEnergy
        ? _accentColor
        : const Color(0xFF7C3AED); // Чуть темнее для стресса

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Светло-серый фон как база
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEnergy ? Icons.flash_on_rounded : Icons.waves,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // Элемент меню (Стиль как FeatureTile из Home)
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _lightAccentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _accentColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[300], size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
