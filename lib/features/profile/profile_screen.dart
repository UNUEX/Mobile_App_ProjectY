// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yauctor_ai/features/auth/auth_screen.dart';
import 'package:yauctor_ai/features/digital_twin/digital_twin_deep_profile.dart';
import 'package:yauctor_ai/features/digital_twin/digital_twin_setup_screen.dart';
import 'package:yauctor_ai/features/digital_twin/digital_twin_avatar_screen.dart';
import 'package:yauctor_ai/features/profile/profile_edit_screen.dart'; // Импортируйте экран редактирования

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- ЛОГИКА СОХРАНЕНИЯ ---
  String _userName = "Traveler";
  String _userEmail = "alex@yauctor.ai";
  bool _isLoggedIn = false;
  String? _avatarUrl; // Добавлено для аватара

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  final Color _primaryPurple = const Color(0xFF8B5CF6);
  final Color _bgPurple = const Color(0xFF9F75F9);

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadUserName();
    _loadAvatar(); // Загружаем аватар
  }

  Future<void> _checkAuthStatus() async {
    final authState = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isLoggedIn = authState != null;
    });

    if (_isLoggedIn) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.email != null) {
        setState(() {
          _userEmail = user.email!;
        });
      }
    }
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Alex Morgan";
    });
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarUrl = prefs.getString('avatarUrl');
    });
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка выхода: $e')));
    }
  }

  void _navigateToAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    ).then((_) {
      _checkAuthStatus();
      _loadUserName();
      _loadAvatar();
    });
  }

  void _navigateToProfileEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
    ).then((value) {
      // Обновляем данные после возврата с экрана редактирования
      if (value == true) {
        _loadUserName();
        _loadAvatar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Фиолетовый фон
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgPurple, _primaryPurple],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- Profile Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Аватар и информация
                        Row(
                          children: [
                            // Аватар с возможностью нажатия
                            InkWell(
                              onTap: _navigateToProfileEdit,
                              borderRadius: BorderRadius.circular(40),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _avatarUrl != null
                                          ? Image.network(
                                              _avatarUrl!,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  color: const Color(
                                                    0xFFE0D4FC,
                                                  ),
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value:
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                          : null,
                                                      color: _primaryPurple,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: const Color(
                                                        0xFFE0D4FC,
                                                      ),
                                                      child: Icon(
                                                        _isLoggedIn
                                                            ? Icons.person
                                                            : Icons
                                                                  .person_outline,
                                                        size: 40,
                                                        color: _primaryPurple,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              color: const Color(0xFFE0D4FC),
                                              child: Icon(
                                                _isLoggedIn
                                                    ? Icons.person
                                                    : Icons.person_outline,
                                                size: 40,
                                                color: _primaryPurple,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: _primaryPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userEmail,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isLoggedIn
                                        ? '✅ Авторизован'
                                        : '⚠️ Не авторизован',
                                    style: TextStyle(
                                      color: _isLoggedIn
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Показываем кнопку авторизации, если пользователь не вошел
                        if (!_isLoggedIn)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _navigateToAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Войти / Зарегистрироваться',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Статистика
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickStat(
                              Icons.calendar_today,
                              "23",
                              "Active Days",
                              const Color(0xFFF3E8FF),
                              _primaryPurple,
                            ),
                            _buildQuickStat(
                              Icons.auto_awesome,
                              "12",
                              "Simulations",
                              const Color(0xFFE0E7FF),
                              const Color(0xFF4F46E5),
                            ),
                            _buildQuickStat(
                              Icons.favorite_border,
                              "18",
                              "Check-ins",
                              const Color(0xFFFCE7F3),
                              const Color(0xFFEC4899),
                            ),
                            _buildQuickStat(
                              Icons.psychology,
                              "34",
                              "Insights",
                              const Color(0xFFDBEAFE),
                              const Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Если пользователь не авторизован, показываем сообщение
                  if (!_isLoggedIn)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFEEBA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange[800],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Авторизация',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Войдите в систему, чтобы синхронизировать данные между устройствами и получить полный доступ ко всем функциям.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- Auth Quick Action ---
                  if (!_isLoggedIn)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryPurple, const Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryPurple.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_open,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Разблокируйте все возможности',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Войдите для синхронизации данных и полного доступа',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _navigateToAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Войти',
                              style: TextStyle(
                                color: _primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- Digital Twin Banner ---
                  InkWell(
                    onTap: () {
                      if (!_isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Пожалуйста, войдите в систему для доступа к Digital Twin',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        _navigateToAuth();
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DigitalTwinAvatarScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryPurple, const Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Digital Twin",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _isLoggedIn
                                            ? "Your AI-powered persona"
                                            : "Авторизуйтесь для доступа",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Profile Completion",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _isLoggedIn ? "85%" : "0%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _isLoggedIn ? 0.85 : 0.0,
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isLoggedIn
                                ? "Complete your twin to unlock deeper simulations"
                                : "Войдите, чтобы создать своего Digital Twin",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- НОВЫЕ ВКЛАДКИ (Quick Setup & Deep Profiler) ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: "Quick Setup",
                          subtitle: "Basic profile",
                          icon: Icons.flash_on,
                          iconColor: _primaryPurple,
                          bgColor: const Color(0xFFF3E8FF),
                          onTap: () {
                            if (!_isLoggedIn) {
                              _navigateToAuth();
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DigitalTwinSetupScreen(),
                              ),
                            ).then((_) {
                              _loadUserName();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          title: "Deep Profiler",
                          subtitle: "Complete analysis",
                          icon: Icons.psychology,
                          iconColor: const Color(0xFF3B82F6),
                          bgColor: const Color(0xFFDBEAFE),
                          onTap: () {
                            if (!_isLoggedIn) {
                              _navigateToAuth();
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DigitalTwinDeepProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- Achievements Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Achievements",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "3/4",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAchievementCard(
                        Icons.star_outline,
                        "First\nSimulation",
                        true,
                      ),
                      _buildAchievementCard(Icons.bolt, "Week\nStreak", true),
                      _buildAchievementCard(
                        Icons.explore_outlined,
                        "Deep\nExplorer",
                        true,
                      ),
                      _buildAchievementCard(
                        Icons.emoji_events_outlined,
                        "Self\nAware",
                        false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- Preferences ---
                  const Text(
                    "PREFERENCES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          "Notifications",
                          Icons.notifications_outlined,
                          _notificationsEnabled,
                          (v) {
                            setState(() => _notificationsEnabled = v);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                        _buildSwitchTile(
                          "Dark Mode",
                          Icons.dark_mode_outlined,
                          _darkModeEnabled,
                          (v) {
                            setState(() => _darkModeEnabled = v);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                        _buildNavTile(
                          "Language",
                          Icons.language,
                          trailing: "English",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Support ---
                  const Text(
                    "SUPPORT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildNavTile("Help Center", Icons.help_outline),
                        Divider(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                        _buildNavTile("Privacy Policy", Icons.shield_outlined),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Log Out / Sign In Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isLoggedIn ? _logout : _navigateToAuth,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _isLoggedIn
                              ? const Color(0xFFFFCCCC)
                              : const Color(0xFF8B5CF6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: Icon(
                        _isLoggedIn ? Icons.logout : Icons.login,
                        color: _isLoggedIn
                            ? Colors.red
                            : const Color(0xFF8B5CF6),
                      ),
                      label: Text(
                        _isLoggedIn ? "Log Out" : "Sign In / Register",
                        style: TextStyle(
                          color: _isLoggedIn
                              ? Colors.red
                              : const Color(0xFF8B5CF6),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Yauctor.ai v1.0.0",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoggedIn
                              ? "Добро пожаловать, $_userName!"
                              : "Ваша личная навигационная платформа",
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для новых карточек
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    IconData icon,
    String value,
    String label,
    Color bg,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }

  // --- Виджет карточки достижения ---
  Widget _buildAchievementCard(IconData icon, String title, bool isActive) {
    return Container(
      width: 75,
      height: 90,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF3E8FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? _primaryPurple : Colors.grey[300],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? _primaryPurple : Colors.grey[400],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // --- Виджет настройки (Switch) ---
  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: _primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // --- Виджет навигации (Arrow Right) ---
  Widget _buildNavTile(String title, IconData icon, {String? trailing}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: title.contains("Help") || title.contains("Language")
                    ? const Color(0xFFE0E7FF)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: title.contains("Help") || title.contains("Language")
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF16A34A),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailing,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }
}
