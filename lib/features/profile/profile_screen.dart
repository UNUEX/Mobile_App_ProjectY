// lib/features/profile/profile_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yauctor_ai/features/auth/auth_screen.dart';
import 'package:yauctor_ai/features/digital_twin/digital_twin_deep_profile.dart';
import 'package:yauctor_ai/features/digital_twin/digital_twin_setup_screen.dart';
import 'package:yauctor_ai/features/digital_twin/digital_twin_avatar_screen.dart';
import 'package:yauctor_ai/features/profile/profile_edit_screen.dart';
import 'package:yauctor_ai/core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = "Traveler";
  String _userEmail = "";
  bool _isLoggedIn = false;
  String? _avatarUrl;
  bool _isLoading = true;

  final Color _primaryPurple = const Color(0xFF8B5CF6);
  final Color _pinkAccent = const Color(0xFFFF6B9D);
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _initAuth() {
    // Используем старый подход с подпиской, так как ref.listen нельзя в initState
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final user = data.session?.user;
      debugPrint('Auth state changed: ${user?.email}');

      if (user != null) {
        _loadUserData(user);
      } else {
        _resetToGuestMode();
      }
    });

    // Проверяем текущее состояние при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      debugPrint('Initial user check: ${user?.email}');

      if (user != null) {
        _loadUserData(user);
      } else {
        _resetToGuestMode();
      }

      setState(() => _isLoading = false);
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      debugPrint('Loading data for user: ${user.email}');

      setState(() {
        _isLoggedIn = true;
        _userEmail = user.email ?? '';
        _userName = "Traveler"; // Временное значение
        _avatarUrl = null;
      });

      // Загружаем из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('userName');
      final savedAvatar = prefs.getString('avatarUrl');

      if (savedName != null) {
        setState(() {
          _userName = savedName;
        });
      }

      if (savedAvatar != null) {
        setState(() {
          _avatarUrl = savedAvatar;
        });
      }

      // Пытаемся загрузить из Supabase
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 5));

        if (response != null) {
          final userName = response['full_name']?.toString();
          final avatarUrl = response['avatar_url']?.toString();

          if (userName != null && userName.isNotEmpty) {
            setState(() {
              _userName = userName;
            });
            await prefs.setString('userName', userName);
          }

          if (avatarUrl != null) {
            setState(() {
              _avatarUrl = avatarUrl;
            });
            await prefs.setString('avatarUrl', avatarUrl);
          }
        }
      } catch (e) {
        debugPrint('Error loading from Supabase: $e');
      }
    } catch (e) {
      debugPrint('Error in _loadUserData: $e');
      _resetToGuestMode();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetToGuestMode() {
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userName = "Traveler";
        _userEmail = "alex@yauctor.ai";
        _avatarUrl = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true);
      await Supabase.instance.client.auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('avatarUrl');

      // Оставляем имя пользователя для будущих сессий
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выхода: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _navigateToProfileEdit() {
    if (!_isLoggedIn) {
      _navigateToAuth();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
    ).then((value) {
      if (value == true) {
        _refreshProfileData();
      }
    });
  }

  Future<void> _refreshProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _loadUserData(user);
    } else {
      _resetToGuestMode();
    }
  }

  // В методе build исправьте эту часть:
  @override
  Widget build(BuildContext context) {
    // currentUserProvider возвращает User? напрямую, не AsyncValue
    final currentUser = ref.watch(currentUserProvider);

    // Синхронизируем состояние при изменении пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentUser != null && !_isLoggedIn) {
        _loadUserData(currentUser);
      } else if (currentUser == null && _isLoggedIn) {
        _resetToGuestMode();
      }
    });

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(child: CircularProgressIndicator(color: _primaryPurple)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: RefreshIndicator(
        onRefresh: _refreshProfileData,
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        if (!_isLoggedIn) _buildAuthPrompt(),
                        if (!_isLoggedIn) const SizedBox(height: 20),
                        _buildActivitiesSection(),
                        const SizedBox(height: 24),
                        _buildDigitalTwinCard(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 32),
                        _buildSettingsSection(),
                        const SizedBox(height: 24),
                        _buildActionButton(),
                        const SizedBox(height: 32),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 140, // Увеличил высоту для размещения всех элементов
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
                _pinkAccent,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Левая часть: меню и статистика
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          // Действие при нажатии на меню
                          debugPrint('Menu tapped');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Last 7 days',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Дополнительные элементы слева
                      InkWell(
                        onTap: () {
                          debugPrint('Left action tapped');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Icon(
                            Icons.trending_up,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Центральная часть: иконка профиля
                InkWell(
                  onTap: _navigateToProfileEdit,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _avatarUrl != null
                          ? Image.network(
                              _avatarUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
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
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: _primaryPurple.withValues(alpha: 0.7),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: _primaryPurple.withValues(alpha: 0.7),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                    ),
                  ),
                ),

                // Правая часть: уведомления и другие элементы
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          // Действие при нажатии на уведомления
                          debugPrint('Notifications tapped');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Дополнительные элементы справа
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              debugPrint('Settings tapped');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Icon(
                                Icons.settings,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 18,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              debugPrint('Search tapped');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Icon(
                                Icons.search,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 18,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Transform.translate(
      offset: const Offset(0, 20),
      child: Column(
        children: [
          const SizedBox(height: 20), // Отступ от AppBar
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isLoggedIn
                    ? [const Color(0xFF4CAF50), const Color(0xFF45B649)]
                    : [_pinkAccent, const Color(0xFFFF8FAB)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isLoggedIn ? const Color(0xFF4CAF50) : _pinkAccent)
                      .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _isLoggedIn ? 'Active' : 'No goal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryPurple, _pinkAccent]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Full Experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sign in to sync and explore',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '120.6 km, Last 7 days',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActivityItem(
                Icons.directions_bike,
                '6.1',
                'km',
                'Distance',
              ),
              const SizedBox(width: 16),
              _buildActivityItem(
                Icons.local_fire_department,
                '300',
                '',
                'Calories',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActivityItem(Icons.terrain, '492', '', 'Elevation'),
              const SizedBox(width: 16),
              _buildActivityItem(Icons.access_time, '5:30', '', 'Time'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return Column(
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: day == 'W' ? _primaryPurple : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: day == 'W' ? _primaryPurple : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String value,
    String unit,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _primaryPurple, size: 24),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalTwinCard() {
    return InkWell(
      onTap: () {
        if (!_isLoggedIn) {
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _primaryPurple.withValues(alpha: 0.1),
              _pinkAccent.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _primaryPurple.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryPurple, _pinkAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Digital Twin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoggedIn ? 'Your AI persona' : 'Sign in to access',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: _primaryPurple, size: 18),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Completion',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  _isLoggedIn ? '85%' : '0%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _isLoggedIn ? 0.85 : 0.0,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Quick Setup',
            'Basic profile',
            Icons.flash_on,
            _primaryPurple,
            () {
              if (!_isLoggedIn) {
                _navigateToAuth();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DigitalTwinSetupScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'Deep Profile',
            'Full analysis',
            Icons.analytics,
            _pinkAccent,
            () {
              if (!_isLoggedIn) {
                _navigateToAuth();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DigitalTwinDeepProfileScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1A1A2E),
              ),
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

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                'Language',
                Icons.language,
                trailing: 'English',
              ),
              Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
              _buildSettingTile('Help Center', Icons.help_outline),
              Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
              _buildSettingTile('Privacy', Icons.shield_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, IconData icon, {String? trailing}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryPurple, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLoggedIn
            ? []
            : [
                BoxShadow(
                  color: _primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoggedIn ? _logout : _navigateToAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoggedIn ? Colors.white : _primaryPurple,
          foregroundColor: _isLoggedIn ? Colors.red : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _isLoggedIn
                ? const BorderSide(color: Colors.red, width: 1.5)
                : BorderSide.none,
          ),
        ),
        icon: Icon(_isLoggedIn ? Icons.logout : Icons.login, size: 22),
        label: Text(
          _isLoggedIn ? 'Log Out' : 'Sign In',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Yauctor.ai v1.0.0',
          style: TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoggedIn
              ? 'Welcome, $_userName!'
              : 'Your personal navigation platform',
          style: TextStyle(color: Colors.grey[300], fontSize: 10),
        ),
      ],
    );
  }
}
