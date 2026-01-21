// lib/features/profile/digital_twin_deep_profile.dart
import 'package:flutter/material.dart';

class DigitalTwinDeepProfileScreen extends StatefulWidget {
  const DigitalTwinDeepProfileScreen({super.key});

  @override
  State<DigitalTwinDeepProfileScreen> createState() =>
      _DigitalTwinDeepProfileScreenState();
}

class _DigitalTwinDeepProfileScreenState
    extends State<DigitalTwinDeepProfileScreen> {
  // Цвета
  final Color _primaryPurple = const Color(0xFF8B5CF6);
  final Color _bgPurple = const Color(0xFFF3E8FF);

  // --- STATE VARIABLES ---

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
    'Growth',
    'Creativity',
    'Authenticity',
    'Stability',
    'Adventure',
    'Family',
    'Career',
    'Health',
  ];
  double _motivationAchievement = 0.7;
  double _motivationAutonomy = 0.5;
  double _motivationBelonging = 0.6;
  double _motivationImpact = 0.8;

  // 3. Life Circumstances
  String _livingSituation = 'Partner';
  String _relationshipStatus = 'Relationship';
  final List<String> _livingOptions = [
    'Alone',
    'Roommates',
    'Partner',
    'Family',
  ];
  final List<String> _relationshipOptions = [
    'Single',
    'Dating',
    'Relationship',
    'Married',
  ];

  // 4. Routines
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 30);
  String _exerciseFreq = '2-3 times';
  String _caffeineIntake = 'Moderate';

  // 5. Finance
  String _incomeLevel = 'Stable';
  String _financialGoal = 'Invest';
  double _riskTolerance = 0.4; // 0 = Conservative, 1 = Aggressive

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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Deep Profiler',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: _primaryPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER PROGRESS ---
            _buildProgressHeader(),
            const SizedBox(height: 24),

            // --- 1. Psychological Profile ---
            _buildSection(
              title: "Psychological Profile",
              icon: Icons.psychology,
              percent: 85,
              content: Column(
                children: [
                  _buildDropdown(
                    "MBTI Type",
                    _selectedMbti,
                    _mbtiTypes,
                    (val) => setState(() => _selectedMbti = val),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    "Enneagram",
                    _selectedEnneagram,
                    _enneagramTypes,
                    (val) => setState(() => _selectedEnneagram = val),
                  ),
                ],
              ),
            ),

            // --- 2. Values & Motivations ---
            _buildSection(
              title: "Values & Motivations",
              icon: Icons.favorite,
              percent: 70,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Core Values (Max 4)"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allValues.map((val) {
                      final isSelected = _selectedValues.contains(val);
                      return FilterChip(
                        label: Text(val),
                        selected: isSelected,
                        selectedColor: _primaryPurple,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (_selectedValues.length < 4) {
                                _selectedValues.add(val);
                              } else {
                                _selectedValues.remove(val);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel("Motivation Drivers"),
                  _buildSliderRow(
                    "Achievement",
                    _motivationAchievement,
                    (v) => setState(() => _motivationAchievement = v),
                  ),
                  _buildSliderRow(
                    "Autonomy",
                    _motivationAutonomy,
                    (v) => setState(() => _motivationAutonomy = v),
                  ),
                  _buildSliderRow(
                    "Belonging",
                    _motivationBelonging,
                    (v) => setState(() => _motivationBelonging = v),
                  ),
                  _buildSliderRow(
                    "Impact",
                    _motivationImpact,
                    (v) => setState(() => _motivationImpact = v),
                  ),
                ],
              ),
            ),

            // --- 3. Life Circumstances ---
            _buildSection(
              title: "Life Circumstances",
              icon: Icons.home,
              percent: 90,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Living Situation"),
                  _buildChoiceChips(
                    _livingOptions,
                    _livingSituation,
                    (val) => setState(() => _livingSituation = val),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel("Relationship Status"),
                  _buildChoiceChips(
                    _relationshipOptions,
                    _relationshipStatus,
                    (val) => setState(() => _relationshipStatus = val),
                  ),
                ],
              ),
            ),

            // --- 4. Routines & Habits ---
            _buildSection(
              title: "Routines & Habits",
              icon: Icons.local_cafe,
              percent: 75,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          "Wake Time",
                          _wakeTime,
                          (t) => setState(() => _wakeTime = t),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePicker(
                          "Sleep Time",
                          _sleepTime,
                          (t) => setState(() => _sleepTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel("Exercise Frequency"),
                  _buildChoiceChips(
                    ['0-1', '2-3', '3-4', '5+'],
                    _exerciseFreq,
                    (val) => setState(() => _exerciseFreq = val),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel("Caffeine Intake"),
                  _buildChoiceChips(
                    ['None', 'Moderate', 'High'],
                    _caffeineIntake,
                    (val) => setState(() => _caffeineIntake = val),
                  ),
                ],
              ),
            ),

            // --- 5. Financial State ---
            _buildSection(
              title: "Financial State",
              icon: Icons.attach_money,
              percent: 60,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Income Level"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildChoiceChips(
                      ['Struggling', 'Stable', 'Comfortable', 'Wealthy'],
                      _incomeLevel,
                      (val) => setState(() => _incomeLevel = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel("Financial Goal"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildChoiceChips(
                      ['Save', 'Invest', 'Debt-free', 'Retire-early'],
                      _financialGoal,
                      (val) => setState(() => _financialGoal = val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel("Risk Tolerance"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Conservative",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        "Aggressive",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  Slider(
                    value: _riskTolerance,
                    activeColor: _primaryPurple,
                    onChanged: (v) => setState(() => _riskTolerance = v),
                  ),
                ],
              ),
            ),

            // --- 6. Health & Wellbeing ---
            _buildSection(
              title: "Health & Wellbeing",
              icon: Icons.spa,
              percent: 80,
              content: Column(
                children: [
                  _buildSliderRow(
                    "Mental Health",
                    _mentalHealth,
                    (v) => setState(() => _mentalHealth = v),
                  ),
                  _buildSliderRow(
                    "Physical Health",
                    _physicalHealth,
                    (v) => setState(() => _physicalHealth = v),
                  ),
                  _buildSliderRow(
                    "Stress Level",
                    _stressLevel,
                    (v) => setState(() => _stressLevel = v),
                    isInverse: true,
                  ), // Inverse color logic maybe?
                  _buildSliderRow(
                    "Sleep Quality",
                    _sleepQuality,
                    (v) => setState(() => _sleepQuality = v),
                  ),
                ],
              ),
            ),

            // --- 7. Goals & Ambitions ---
            _buildSection(
              title: "Goals & Ambitions",
              icon: Icons.flag,
              percent: 55,
              content: Column(
                children: [
                  _buildTextField(
                    "Short-term Goals (6-12 mo)",
                    _shortTermGoalCtrl,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Long-term Goals (2-5 yrs)",
                    _longTermGoalCtrl,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Dream Scenario (10 yrs)",
                    _dreamScenarioCtrl,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            // --- 8. Fears & Limitations ---
            _buildSection(
              title: "Fears & Limitations",
              icon: Icons.warning_amber_rounded,
              percent: 65,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Common Fears"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonFears.map((val) {
                      final isSelected = _selectedFears.contains(val);
                      return FilterChip(
                        label: Text(val),
                        selected: isSelected,
                        selectedColor: Colors.red[100],
                        checkmarkColor: Colors.red,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.red[900] : Colors.black87,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            selected
                                ? _selectedFears.add(val)
                                : _selectedFears.remove(val);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    "Perceived Limitations",
                    _limitationsCtrl,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryPurple, const Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Profile Completion',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.72, // Calculated average roughly
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '72%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Complete more sections to improve simulation accuracy.",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required int percent,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _bgPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryPurple, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "$percent% complete",
            style: TextStyle(
              color: percent == 100 ? Colors.green : Colors.grey[500],
              fontSize: 12,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [const Divider(), const SizedBox(height: 10), content],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text("Select $label"),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    Function(double) onChanged, {
    bool isInverse = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryPurple,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: isInverse ? Colors.orange[300] : _primaryPurple,
            inactiveTrackColor: Colors.grey[200],
            thumbColor: isInverse ? Colors.orange : _primaryPurple,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildChoiceChips(
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: _primaryPurple,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          onSelected: (bool selected) {
            if (selected) onSelect(option);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(primary: _primaryPurple),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onSelect(picked);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter details...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryPurple),
            ),
          ),
        ),
      ],
    );
  }
}
