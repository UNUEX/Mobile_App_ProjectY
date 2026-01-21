// lib/features/onboarding/welcome_questionnaire_screen.dart
import 'dart:ui';
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

  int _currentPage = 0;
  String? _selectedFocus;

  // Цветовая палитра в стиле Harmont (Natural/Earth tones + Glass)
  final Color _seedWhite = const Color(0xFFF2F2F7);
  final Color _glassBorder = const Color(0xFFFFFFFF).withValues(alpha: 0.3);
  final Color _accentGold = const Color(
    0xFFD4C085,
  ); // Цвет иконки/кнопки с фото

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
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

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Сброс анимации для плавного появления элементов на новой странице
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Используем Stack для фона и контента
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // Чтобы клавиатура не ломала фон
      body: Stack(
        children: [
          // 1. ФОНОВОЕ ИЗОБРАЖЕНИЕ (Стиль Harmont - природа/горы)
          Positioned.fill(
            child: Image.network(
              // URL заглушка (Горы/Туман - символизирует поиск пути)
              'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: const Color(0xFF1A1A2E));
              },
              errorBuilder: (context, error, stackTrace) {
                // Фолбэк градиент если нет интернета
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. ЗАТЕМНЕНИЕ (Градиент снизу вверх для читаемости)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. КОНТЕНТ
          SafeArea(
            child: Column(
              children: [
                // Header (Логотип и кнопка пропуска/уведомлений)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: _accentGold,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Yauctor",
                            style: TextStyle(
                              color: _seedWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // Индикатор страниц вместо колокольчика
                      if (_currentPage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _glassBorder),
                          ),
                          child: Text(
                            "${_currentPage + 1} / 3",
                            style: TextStyle(
                              color: _seedWhite.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

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

          // 4. НИЖНЯЯ ПАНЕЛЬ (Вместо навбара - кнопка действия)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(child: _buildBottomAction()),
          ),
        ],
      ),
    );
  }

  // --- ЭКРАН 1: ПРИВЕТСТВИЕ (Стиль Harmont) ---
  Widget _buildWelcomePage() {
    return Stack(
      children: [
        // Плавающие теги (как на скрине "Wifi", "Pet Friendly")
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          right: 20,
          child: _buildFloatingTag("Deep Analytics", delay: 200),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          left: -20, // Слегка за краем
          child: _buildFloatingTag("Personal Growth", delay: 400),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.25,
          right: 40,
          child: _buildFloatingTag("Secure Space", delay: 600),
        ),

        // Основной текст
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    Text(
                      "Find Your\nInner Path",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:
                            'Serif', // Если есть шрифт типа Playfair Display
                        fontSize: 48,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        color: _seedWhite,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Discover insights hidden within your daily life.\nUnplug noise, reconnect with purpose.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _seedWhite.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Место под нижнюю панель
            ],
          ),
        ),
      ],
    );
  }

  // --- ЭКРАН 2: ВВОД ИМЕНИ ---
  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Let's Start".toUpperCase(),
              style: TextStyle(
                color: _accentGold,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What should we call you?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: _seedWhite,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 48),
            // Glass input field
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _glassBorder),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 20,
                      color: _seedWhite,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: _accentGold,
                    decoration: InputDecoration(
                      hintText: "Your Name",
                      hintStyle: TextStyle(
                        color: _seedWhite.withValues(alpha: 0.3),
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ЭКРАН 3: ФОКУС ---
  Widget _buildFocusPage() {
    final options = [
      "Career Growth",
      "Inner Balance",
      "Reducing Stress",
      "New Horizons",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Goal".toUpperCase(),
              style: TextStyle(
                color: _accentGold,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "What matters most right now?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: _seedWhite,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGlassOption(option),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- КОМПОНЕНТЫ ---

  // "Плавающий тег" (как Wi-Fi 100 Mbps на картинке)
  Widget _buildFloatingTag(String text, {required int delay}) {
    // Простая анимация появления
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final visible = snapshot.connectionState == ConnectionState.done;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: visible ? 1.0 : 0.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_outlined, size: 14, color: _accentGold),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        color: _seedWhite,
                        fontWeight: FontWeight.w500,
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

  // Стеклянная карточка выбора
  Widget _buildGlassOption(String text) {
    final isSelected = _selectedFocus == text;

    return GestureDetector(
      onTap: () => setState(() => _selectedFocus = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentGold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? _accentGold.withValues(alpha: 0.5)
                : _glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: _seedWhite,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: _accentGold, size: 20),
          ],
        ),
      ),
    );
  }

  // Нижняя кнопка (Вместо навбара Home)
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
      onTap: action,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 220, // Ширина пилюли
            height: 64,
            decoration: BoxDecoration(
              // Цвет кнопки: если не активна - серый, иначе - фирменный песочный
              color: action == null
                  ? Colors.white.withValues(alpha: 0.1)
                  : _accentGold.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка слева (или аватарка как в оригинале, тут иконка действия)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: action == null ? Colors.white38 : Colors.black87,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  buttonText,
                  style: TextStyle(
                    color: action == null ? Colors.white38 : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 20), // Баланс справа
              ],
            ),
          ),
        ),
      ),
    );
  }
}
