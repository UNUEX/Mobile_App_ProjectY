// lib/features/profile/digital_twin_deep_profile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DigitalTwinDeepProfileScreen extends StatefulWidget {
  const DigitalTwinDeepProfileScreen({super.key});

  @override
  State<DigitalTwinDeepProfileScreen> createState() =>
      _DigitalTwinDeepProfileScreenState();
}

class _DigitalTwinDeepProfileScreenState
    extends State<DigitalTwinDeepProfileScreen> {
  // Цветовая палитра (Modern Violet Theme)
  final Color _primaryColor = const Color(0xFF7C3AED); // Deep Violet
  // Soft Violet
  final Color _backgroundColor = const Color(0xFFF3F4F6); // Cool Grey
  final Color _surfaceColor = Colors.white;

  // --- STATE VARIABLES (Логика сохранена) ---

  // 1. Psychological
  String? _selectedMbti;
  String? _selectedEnneagram;
  final List<String> _mbtiTypes = [
    'INTJ',
    'INTP',
    'ENTJ',
    'ENTP',
    'INFJ',
    'INFP',
    'ENFJ',
    'ENFP',
    'ISTJ',
    'ISFJ',
    'ESTJ',
    'ESFJ',
    'ISTP',
    'ISFP',
    'ESTP',
    'ESFP',
  ];
  final List<String> _enneagramTypes = [
    'Type 1: The Reformer',
    'Type 2: The Helper',
    'Type 3: The Achiever',
    'Type 4: The Individualist',
    'Type 5: The Investigator',
    'Type 6: The Loyalist',
    'Type 7: The Enthusiast',
    'Type 8: The Challenger',
    'Type 9: The Peacemaker',
  ];

  // 2. Values & Motivations
  final Set<String> _selectedValues = {};
  final List<String> _allValues = [
    '🌱 Growth',
    '🎨 Creativity',
    '💎 Authenticity',
    '🛡 Stability',
    '🧗 Adventure',
    '👨‍👩‍👧 Family',
    '💼 Career',
    '❤️ Health',
  ];
  double _motivationAchievement = 0.7;
  double _motivationAutonomy = 0.5;
  double _motivationBelonging = 0.6;
  double _motivationImpact = 0.8;

  // 3. Life Circumstances
  String _livingSituation = 'Partner';
  String _relationshipStatus = 'Relationship';
  final List<Map<String, dynamic>> _livingOptions = [
    {'label': 'Alone', 'icon': '🏠'},
    {'label': 'Roommates', 'icon': '🤝'},
    {'label': 'Partner', 'icon': '❤️'},
    {'label': 'Family', 'icon': '👨‍👩‍👧'},
  ];
  final List<Map<String, dynamic>> _relationshipOptions = [
    {'label': 'Single', 'icon': '👤'},
    {'label': 'Dating', 'icon': '🥂'},
    {'label': 'Relationship', 'icon': '🔒'},
    {'label': 'Married', 'icon': '💍'},
  ];

  // 4. Routines
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 30);
  String _exerciseFreq = '2-3 times';
  String _caffeineIntake = 'Moderate';

  // 5. Finance
  String _incomeLevel = 'Stable';
  String _financialGoal = 'Invest';
  double _riskTolerance = 0.4;

  // 6. Health
  double _mentalHealth = 0.8;
  double _physicalHealth = 0.7;
  double _stressLevel = 0.4;
  double _sleepQuality = 0.75;

  // 7. Goals
  final TextEditingController _shortTermGoalCtrl = TextEditingController();
  final TextEditingController _longTermGoalCtrl = TextEditingController();
  final TextEditingController _dreamScenarioCtrl = TextEditingController();

  // 8. Fears
  final Set<String> _selectedFears = {};
  final List<String> _commonFears = [
    'Failure',
    'Loneliness',
    'Rejection',
    'Uncertainty',
    'Loss of control',
    'Mediocrity',
  ];
  final TextEditingController _limitationsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Вычисляем процент заполнения для хедера
    final double progress = 0.72; // Hardcoded simulation

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(progress),
                  const SizedBox(height: 32),

                  _buildSectionHeader("🧠 Psychology", "How you think"),
                  _buildPsychologySection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("💎 Values & Drivers", "What moves you"),
                  _buildValuesSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("🏡 Lifestyle", "Your environment"),
                  _buildLifestyleSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("⚡️ Energy & Habits", "Daily rhythm"),
                  _buildRoutinesSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("💰 Finance", "Resources & Goals"),
                  _buildFinanceSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("❤️ Wellness", "Body & Mind"),
                  _buildHealthSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("🚀 Future Self", "Goals & Ambitions"),
                  _buildGoalsSection(),

                  const SizedBox(height: 32),
                  _buildSectionHeader("🛑 Blockers", "Fears & Limits"),
                  _buildFearsSection(),

                  const SizedBox(height: 50),
                  _buildSaveButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: _backgroundColor,
      elevation: 0,
      floating: true,
      pinned: true,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black87,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Digital Twin",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildProgressCard(double percent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, const Color(0xFF6025C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                Center(
                  child: Text(
                    "${(percent * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile Strength",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Complete more sections to make your AI twin indistinguishable from you.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // --- SECTIONS ---

  Widget _buildPsychologySection() {
    return Row(
      children: [
        Expanded(
          child: _buildSelectorTile(
            label: "MBTI",
            value: _selectedMbti ?? "Select",
            color: Colors.blueAccent.withValues(alpha: 0.1),
            textColor: Colors.blue[800]!,
            onTap: () => _showSelectionSheet("MBTI Type", _mbtiTypes, (val) {
              setState(() => _selectedMbti = val);
            }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSelectorTile(
            label: "Enneagram",
            value: _selectedEnneagram != null
                ? _selectedEnneagram!.split(':')[0]
                : "Select",
            color: Colors.orangeAccent.withValues(alpha: 0.1),
            textColor: Colors.orange[900]!,
            onTap: () =>
                _showSelectionSheet("Enneagram", _enneagramTypes, (val) {
                  setState(() => _selectedEnneagram = val);
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildValuesSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Core Values",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _allValues.map((val) {
              final isSelected = _selectedValues.contains(val);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedValues.remove(val);
                    } else if (_selectedValues.length < 4) {
                      _selectedValues.add(val);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    val,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          const Text(
            "Motivations",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildModernSlider(
            "Achievement",
            _motivationAchievement,
            (v) => setState(() => _motivationAchievement = v),
          ),
          _buildModernSlider(
            "Autonomy",
            _motivationAutonomy,
            (v) => setState(() => _motivationAutonomy = v),
          ),
          _buildModernSlider(
            "Belonging",
            _motivationBelonging,
            (v) => setState(() => _motivationBelonging = v),
          ),
          _buildModernSlider(
            "Impact",
            _motivationImpact,
            (v) => setState(() => _motivationImpact = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      children: [
        _buildIconGridSelector(
          title: "Living Situation",
          options: _livingOptions,
          selectedValue: _livingSituation,
          onSelect: (val) => setState(() => _livingSituation = val),
        ),
        const SizedBox(height: 16),
        _buildIconGridSelector(
          title: "Relationship",
          options: _relationshipOptions,
          selectedValue: _relationshipStatus,
          onSelect: (val) => setState(() => _relationshipStatus = val),
        ),
      ],
    );
  }

  Widget _buildRoutinesSection() {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  "☀️ Wake Up",
                  _wakeTime,
                  (t) => setState(() => _wakeTime = t),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeCard(
                  "🌙 Sleep",
                  _sleepTime,
                  (t) => setState(() => _sleepTime = t),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPillSelector(
            "Exercise / Week",
            ['0-1', '2-3', '3-4', '5+'],
            _exerciseFreq,
            (val) => setState(() => _exerciseFreq = val),
          ),
          const SizedBox(height: 24),
          _buildPillSelector(
            "Caffeine",
            ['None', 'Moderate', 'High'],
            _caffeineIntake,
            (val) => setState(() => _caffeineIntake = val),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPillSelector(
            "Income Stability",
            ['Struggling', 'Stable', 'Comfortable', 'Wealthy'],
            _incomeLevel,
            (val) => setState(() => _incomeLevel = val),
          ),
          const SizedBox(height: 24),
          _buildPillSelector(
            "Primary Goal",
            ['Save', 'Invest', 'Debt-free', 'Retire-early'],
            _financialGoal,
            (val) => setState(() => _financialGoal = val),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Risk Tolerance",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _riskTolerance < 0.3
                    ? "Conservative"
                    : _riskTolerance > 0.7
                    ? "Aggressive"
                    : "Balanced",
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.green.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayColor: Colors.green.withValues(alpha: 0.2),
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 2,
              ),
            ),
            child: Slider(
              value: _riskTolerance,
              onChanged: (v) => setState(() => _riskTolerance = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    return _buildCard(
      child: Column(
        children: [
          _buildModernSlider(
            "🧠 Mental Health",
            _mentalHealth,
            (v) => setState(() => _mentalHealth = v),
          ),
          _buildModernSlider(
            "💪 Physical Body",
            _physicalHealth,
            (v) => setState(() => _physicalHealth = v),
          ),
          _buildModernSlider(
            "⚡️ Stress Level",
            _stressLevel,
            (v) => setState(() => _stressLevel = v),
            isNegative: true,
          ),
          _buildModernSlider(
            "💤 Sleep Quality",
            _sleepQuality,
            (v) => setState(() => _sleepQuality = v),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      children: [
        _buildModernTextField("Short Term (6 mo)", _shortTermGoalCtrl),
        const SizedBox(height: 16),
        _buildModernTextField("Long Term (5 yrs)", _longTermGoalCtrl),
        const SizedBox(height: 16),
        _buildModernTextField(
          "Dream Life (10 yrs)",
          _dreamScenarioCtrl,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildFearsSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonFears.map((val) {
              final isSelected = _selectedFears.contains(val);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected
                        ? _selectedFears.remove(val)
                        : _selectedFears.add(val);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red[50] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey[200]!,
                    ),
                  ),
                  child: Text(
                    val,
                    style: TextStyle(
                      color: isSelected ? Colors.red[700] : Colors.grey[700],
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _limitationsCtrl,
            decoration: InputDecoration(
              labelText: "Any limiting beliefs?",
              labelStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Save Deep Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconGridSelector({
    required String title,
    required List<Map<String, dynamic>> options,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((opt) {
            bool isSelected = selectedValue == opt['label'];
            return GestureDetector(
              onTap: () => onSelect(opt['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (MediaQuery.of(context).size.width - 40 - (3 * 10)) / 4,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(opt['icon'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      opt['label'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeCard(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onSelect,
  ) {
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onSelect(t);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time.format(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillSelector(
    String label,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              bool isSelected = selected == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (_) => onSelect(opt),
                  selectedColor: Colors.black87,
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSlider(
    String label,
    double value,
    Function(double) onChanged, {
    bool isNegative = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              "${(value * 10).toInt()}/10",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isNegative ? Colors.orange : _primaryColor,
            inactiveTrackColor: Colors.grey[100],
            trackHeight: 16,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 3,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildModernTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  void _showSelectionSheet(
    String title,
    List<String> items,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index], textAlign: TextAlign.center),
                      onTap: () {
                        onSelect(items[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
