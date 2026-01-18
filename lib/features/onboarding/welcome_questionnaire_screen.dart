// lib/features/onboarding/welcome_questionnaire_screen.dart
import 'package:flutter/material.dart';
import 'package:yauctor_ai/ui/layout/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeQuestionnaireScreen extends StatefulWidget {
  const WelcomeQuestionnaireScreen({super.key});

  @override
  State<WelcomeQuestionnaireScreen> createState() =>
      _WelcomeQuestionnaireScreenState();
}

class _WelcomeQuestionnaireScreenState
    extends State<WelcomeQuestionnaireScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentPage = 0;
  String? _selectedFocus;

  // Основной цвет (фиолетовый)
  final Color _accentColor = const Color(0xFF8B5CF6);

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  // Обнови функцию _finishOnboarding:
  void _finishOnboarding() async {
    // 1. Сохраняем имя
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);

    if (!mounted) return;

    // 2. Переходим на Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Показываем прогресс-бар только если это не первый экран (Приветствие)
            if (_currentPage > 0) _buildProgressBar(),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Блокируем свайп, только кнопки
                onPageChanged: _onPageChanged,
                children: [
                  _buildWelcomePage(), // Экран 1: Yauctor
                  _buildNamePage(), // Экран 2: Имя
                  _buildFocusPage(), // Экран 3: Фокус (Опрос)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. WELCOME SCREEN ---
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.auto_awesome, size: 48, color: _accentColor),
          ),
          const SizedBox(height: 32),
          const Text(
            "Yauctor.ai",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your personal navigation platform.\nUnderstand your state, explore paths.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const Spacer(),
          _buildPrimaryButton(text: "Get Started", onPressed: _nextPage),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- 2. NAME INPUT SCREEN ---
  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "What should we call you?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Your digital twin needs a name.",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter your name",
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: (value) =>
                setState(() {}), // Обновляем UI, чтобы активировать кнопку
          ),
          const Spacer(),
          _buildPrimaryButton(
            text: "Continue",
            onPressed: _nameController.text.isNotEmpty ? _nextPage : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- 3. FOCUS SCREEN (SURVEY) ---
  Widget _buildFocusPage() {
    final options = [
      "Career & Growth",
      "Finding Balance",
      "Reducing Stress",
      "Exploring New Paths",
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "What is your main focus?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll adapt the simulation to you.",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedFocus = option),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedFocus == option
                        ? _accentColor.withValues(alpha: .05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFocus == option
                          ? _accentColor
                          : Colors.grey.withValues(alpha: 0.2),
                      width: _selectedFocus == option ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedFocus == option
                              ? _accentColor
                              : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedFocus == option)
                        Icon(Icons.check_circle, color: _accentColor, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          _buildPrimaryButton(
            text: "Create My Space",
            onPressed: _selectedFocus != null ? _nextPage : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildProgressBar() {
    // 0.5 для экрана имени (1 из 2 шагов ввода), 1.0 для экрана фокуса
    double progress = (_currentPage == 1) ? 0.5 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "$_currentPage/2",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          disabledBackgroundColor: _accentColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
