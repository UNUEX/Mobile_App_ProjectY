// lib/features/onboarding/welcome_questionnaire_screen.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yauctor_ai/ui/layout/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeQuestionnaireScreen extends StatefulWidget {
  const WelcomeQuestionnaireScreen({super.key});

  @override
  State<WelcomeQuestionnaireScreen> createState() =>
      _WelcomeQuestionnaireScreenState();
}

class _WelcomeQuestionnaireScreenState extends State<WelcomeQuestionnaireScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  late final AnimationController _fadeController;
  late final AnimationController _floatingController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  int _currentPage = 0;
  String? _selectedFocus;

  // Цветовая палитра
  final Color _seedWhite = const Color(0xFFF2F2F7);
  final Color _glassBorder = const Color(0xFFFFFFFF).withValues(alpha: 0.3);
  final Color _accentGold = const Color(0xFFD4C085);
  final Color _accentPurple = const Color(0xFF9B87C4);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Добавляем задержку для плавного появления контента
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    if (_selectedFocus != null) {
      await prefs.setString('userFocus', _selectedFocus!);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _showHintIfNeeded() {
    if (_currentPage == 1 && _nameController.text.isEmpty) {
      _showHintAnimation("Please enter your name to continue");
    } else if (_currentPage == 2 && _selectedFocus == null) {
      _showHintAnimation("Select your focus to proceed");
    }
  }

  void _showHintAnimation(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: FadeTransition(
            opacity: _fadeController.drive(CurveTween(curve: Curves.easeInOut)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentGold.withValues(alpha: 0.2),
                    _accentPurple.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _glassBorder),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: _seedWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Gradient Overlay
          _buildGradientOverlay(),

          // Animated Particles
          _buildFloatingParticles(),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildWelcomePage(),
                      _buildNamePage(),
                      _buildFocusPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(child: _buildBottomAction()),
          ),

          // Progress Dots
          if (_currentPage > 0)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: _buildProgressDots(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Positioned.fill(
          child: Stack(
            children: [
              // Base Image
              Image.network(
                'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          const Color(0xFF0F3460),
                        ],
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2C3E50),
                          const Color(0xFF000000),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Animated overlay for depth
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: 0.3 + (_shimmerController.value * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 2.0,
                        colors: [
                          _accentPurple.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.3, 0.65, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final offset =
                _floatingController.value * 30 * (index % 2 == 0 ? 1 : -1);
            return Positioned(
              left: 50.0 + (index * 45.0),
              top: 100.0 + offset + (index * 80.0),
              child: Opacity(
                opacity:
                    0.15 +
                    (0.1 * math.sin(_floatingController.value * math.pi)),
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index % 2 == 0 ? _accentGold : _accentPurple,
                    boxShadow: [
                      BoxShadow(
                        color: (index % 2 == 0 ? _accentGold : _accentPurple)
                            .withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_accentGold, _accentPurple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accentGold.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [_accentGold, _accentPurple],
                ).createShader(bounds),
                child: const Text(
                  "Yauctor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          if (_currentPage > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentGold.withValues(alpha: 0.3),
                    _accentPurple.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _glassBorder),
              ),
              child: Text(
                "${_currentPage + 1} / 3",
                style: TextStyle(
                  color: _seedWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Stack(
      children: [
        // Floating Interactive Tags
        ..._buildInteractiveTags(),

        // Main Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    // Animated Title with Gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [_seedWhite, _accentGold, _accentPurple],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: const Text(
                        "Find Your\nInner Path",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 56,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Animated Underline
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          width: 100 + (_shimmerController.value * 50),
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_accentGold, _accentPurple],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Discover insights hidden within your daily life.\nUnplug noise, reconnect with purpose.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: _seedWhite.withValues(alpha: 0.8),
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInteractiveTags() {
    final tags = [
      {
        "text": "Deep Analytics",
        "icon": Icons.analytics_outlined,
        "top": 0.15,
        "left": null,
        "right": 20.0,
      },
      {
        "text": "Personal Growth",
        "icon": Icons.trending_up,
        "top": 0.35,
        "left": 20.0,
        "right": null,
      },
      {
        "text": "Secure Space",
        "icon": Icons.security,
        "top": 0.22,
        "left": null,
        "right": 60.0,
      },
      {
        "text": "AI Insights",
        "icon": Icons.psychology,
        "top": 0.45,
        "left": null,
        "right": 30.0,
      },
    ];

    return tags.asMap().entries.map((entry) {
      final index = entry.key;
      final tag = entry.value;

      return AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final offset =
              math.sin(_floatingController.value * math.pi + index) * 10;

          return Positioned(
            top:
                MediaQuery.of(context).size.height * (tag["top"] as double) +
                offset,
            left: tag["left"] as double?,
            right: tag["right"] as double?,
            child: _buildFloatingTag(
              tag["text"] as String,
              tag["icon"] as IconData,
              delay: 200 * index,
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.15),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_accentGold, _accentPurple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accentGold.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              "LET'S START",
              style: TextStyle(
                color: _accentGold,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What should we\ncall you?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w600,
                color: _seedWhite,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 48),
            // Enhanced Glass Input
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(
                          alpha: _nameController.text.isEmpty ? 0.1 : 0.15,
                        ),
                        Colors.white.withValues(
                          alpha: _nameController.text.isEmpty ? 0.05 : 0.1,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _nameController.text.isEmpty
                          ? _glassBorder
                          : _accentGold.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: _nameController.text.isNotEmpty
                        ? [
                            BoxShadow(
                              color: _accentGold.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 22,
                      color: _seedWhite,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: _accentGold,
                    decoration: InputDecoration(
                      hintText: "Your Name",
                      hintStyle: TextStyle(
                        color: _seedWhite.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ),
            ),
            if (_nameController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    "Nice to meet you! 👋",
                    style: TextStyle(
                      color: _accentGold,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusPage() {
    final options = [
      {
        "text": "Career Growth",
        "icon": Icons.work_outline,
        "desc": "Level up professionally",
      },
      {
        "text": "Inner Balance",
        "icon": Icons.self_improvement,
        "desc": "Find your center",
      },
      {
        "text": "Reducing Stress",
        "icon": Icons.spa_outlined,
        "desc": "Peace of mind",
      },
      {
        "text": "New Horizons",
        "icon": Icons.explore_outlined,
        "desc": "Discover yourself",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "YOUR GOAL",
              style: TextStyle(
                color: _accentGold,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What matters most\nright now?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
                color: _seedWhite,
                height: 1.1,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 40),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildEnhancedOption(
                  option["text"] as String,
                  option["icon"] as IconData,
                  option["desc"] as String,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTag(String text, IconData icon, {required int delay}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final visible = snapshot.connectionState == ConnectionState.done;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          opacity: visible ? 1.0 : 0.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _glassBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _accentGold.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: _accentGold),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: TextStyle(
                        color: _seedWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedOption(String text, IconData icon, String description) {
    final isSelected = _selectedFocus == text;

    return GestureDetector(
      onTap: () => setState(() => _selectedFocus = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _accentGold.withValues(alpha: 0.3),
                    _accentPurple.withValues(alpha: 0.2),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? _accentGold.withValues(alpha: 0.6)
                : _glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accentGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [_accentGold, _accentPurple]
                      : [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : _seedWhite.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: _seedWhite,
                      fontSize: 17,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: _seedWhite.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accentGold, _accentPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(colors: [_accentGold, _accentPurple])
                : null,
            color: isActive ? null : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildBottomAction() {
    String buttonText = "Get Started";
    VoidCallback? action = _nextPage;
    IconData icon = Icons.arrow_forward;

    if (_currentPage == 1) {
      buttonText = "Continue";
      action = _nameController.text.isNotEmpty ? _nextPage : null;
    } else if (_currentPage == 2) {
      buttonText = "Start Journey";
      icon = Icons.rocket_launch;
      action = _selectedFocus != null ? _nextPage : null;
    }

    return GestureDetector(
      onTap: () {
        if (action != null) {
          action();
        } else {
          _showHintIfNeeded();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 240,
              height: 70,
              decoration: BoxDecoration(
                gradient: action != null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accentGold, _accentPurple],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: action != null
                    ? [
                        BoxShadow(
                          color: _accentGold.withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: action != null
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: action != null ? Colors.white : Colors.white38,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: action != null ? Colors.white : Colors.white60,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
