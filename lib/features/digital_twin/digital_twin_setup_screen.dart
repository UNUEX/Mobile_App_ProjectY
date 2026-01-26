// lib/features/profile/digital_twin_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DigitalTwinSetupScreen extends StatefulWidget {
  const DigitalTwinSetupScreen({super.key});

  @override
  State<DigitalTwinSetupScreen> createState() => _DigitalTwinSetupScreenState();
}

class _DigitalTwinSetupScreenState extends State<DigitalTwinSetupScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Данные формы
  final TextEditingController _nameController = TextEditingController(
    text: "Alex",
  );
  final TextEditingController _ageController = TextEditingController(
    text: "28",
  );
  final TextEditingController _roleController = TextEditingController(
    text: "Product Designer",
  );

  // Значения слайдеров (Personality)
  double _openness = 0.75;
  double _conscientiousness = 0.68;
  double _extraversion = 0.45;
  double _agreeableness = 0.82;
  double _sensitivity = 0.38;

  // Значения слайдеров (Work Style)
  double _deepWork = 0.70;
  double _collaboration = 0.55;
  double _flexibility = 0.65;

  // Preferences
  String _selectedTime = "Morning";
  String _selectedWork = "Hybrid";
  final Set<String> _selectedInterests = {"Design", "Reading"};

  final Color _primaryPurple = const Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryPurple, // Фиолетовый фон страницы
      appBar: AppBar(
        backgroundColor: _primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Avatar Setup",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Stepper Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepIcon(0, Icons.person_outline, "Basic\nInfo"),
                _buildStepLine(0),
                _buildStepIcon(1, Icons.psychology_outlined, "Personality"),
                _buildStepLine(1),
                _buildStepIcon(2, Icons.work_outline, "Work\nStyle"),
                _buildStepLine(2),
                _buildStepIcon(3, Icons.favorite_border, "Preferences"),
                _buildStepLine(3),
                _buildStepIcon(4, Icons.check, "Review"),
              ],
            ),
          ),

          // --- White Content Area ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStepContent(),
                    ),
                  ),

                  // Bottom Button
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == 4 ? "Complete Setup" : "Continue",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_currentStep != 4)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic ---

  Future<void> _nextStep() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Сохраняем имя при завершении (как пример)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);

      if (mounted) Navigator.pop(context);
    }
  }

  // --- Widgets ---

  Widget _buildStepIcon(int stepIndex, IconData icon, String label) {
    bool isActive = _currentStep >= stepIndex;
    bool isCurrent = _currentStep == stepIndex;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: isActive
                ? _primaryPurple
                : Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    bool isActive = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
        margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildPersonalityStep();
      case 2:
        return _buildWorkStyleStep();
      case 3:
        return _buildPreferencesStep();
      case 4:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  // --- STEP 1: Basic Info ---
  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        _buildStepHeader(
          Icons.person_outline,
          "Let's start with the basics",
          "Help us understand who you are",
        ),
        const SizedBox(height: 32),
        _buildTextField("What should we call you?", _nameController),
        const SizedBox(height: 20),
        _buildTextField("Age", _ageController, isNumber: true),
        const SizedBox(height: 20),
        _buildTextField("Current Role / Situation", _roleController),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "This information helps your Digital Twin simulate scenarios that are relevant to your life context.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STEP 2: Personality ---
  Widget _buildPersonalityStep() {
    return Column(
      children: [
        _buildStepHeader(
          Icons.psychology_outlined,
          "Your Personality",
          "How would you describe yourself?",
        ),
        const SizedBox(height: 32),
        _buildSlider(
          "Openness",
          "Curiosity and willingness to try new things",
          _openness,
          (v) => setState(() => _openness = v),
        ),
        _buildSlider(
          "Conscientiousness",
          "Organization and attention to detail",
          _conscientiousness,
          (v) => setState(() => _conscientiousness = v),
        ),
        _buildSlider(
          "Extraversion",
          "Social energy and outgoing nature",
          _extraversion,
          (v) => setState(() => _extraversion = v),
        ),
        _buildSlider(
          "Agreeableness",
          "Cooperation and empathy",
          _agreeableness,
          (v) => setState(() => _agreeableness = v),
        ),
        _buildSlider(
          "Emotional Sensitivity",
          "Reactivity to stress and emotions",
          _sensitivity,
          (v) => setState(() => _sensitivity = v),
        ),
      ],
    );
  }

  // --- STEP 3: Work Style ---
  Widget _buildWorkStyleStep() {
    return Column(
      children: [
        _buildStepHeader(
          Icons.work_outline,
          "Work Style",
          "How do you work best?",
        ),
        const SizedBox(height: 32),
        _buildSlider(
          "Deep Work",
          "Extended focused sessions",
          _deepWork,
          (v) => setState(() => _deepWork = v),
        ),
        _buildSlider(
          "Collaboration",
          "Working with others",
          _collaboration,
          (v) => setState(() => _collaboration = v),
        ),
        _buildSlider(
          "Flexibility",
          "Adapting to changes",
          _flexibility,
          (v) => setState(() => _flexibility = v),
        ),
      ],
    );
  }

  // --- STEP 4: Preferences ---
  Widget _buildPreferencesStep() {
    return Column(
      children: [
        _buildStepHeader(
          Icons.favorite_border,
          "Preferences",
          "Your habits and interests",
        ),
        const SizedBox(height: 32),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "When are you most productive?",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSelectCard(
                "Morning",
                Icons.wb_sunny_outlined,
                _selectedTime == "Morning",
                () => setState(() => _selectedTime = "Morning"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectCard(
                "Night",
                Icons.nightlight_round,
                _selectedTime == "Night",
                () => setState(() => _selectedTime = "Night"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Preferred work environment",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ["Remote", "Hybrid", "Office"].map((e) {
            bool selected = _selectedWork == e;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _selectedWork = e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? _primaryPurple : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Your interests", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildInterestChip("Design", Icons.auto_awesome),
            _buildInterestChip("Reading", Icons.book),
            _buildInterestChip("Fitness", Icons.fitness_center),
            _buildInterestChip("Music", Icons.music_note),
            _buildInterestChip("Coffee", Icons.coffee),
          ],
        ),
      ],
    );
  }

  // --- STEP 5: Review ---
  Widget _buildReviewStep() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.check, size: 40, color: Color(0xFF16A34A)),
        ),
        const SizedBox(height: 16),
        const Text(
          "Your Digital Twin",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text("Review and confirm", style: TextStyle(color: Colors.grey)),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _primaryPurple,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${_ageController.text} • ${_roleController.text}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Energy Peak",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _selectedTime,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Work Style",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedWork,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personality Highlights",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: const Text("Openness"),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    labelStyle: TextStyle(color: _primaryPurple),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text("Agreeableness"),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    labelStyle: TextStyle(color: _primaryPurple),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF15803D)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Twin is Ready!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14532D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your digital twin will use this profile to simulate realistic scenarios.",
                      style: TextStyle(fontSize: 12, color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildStepHeader(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 32, color: _primaryPurple),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
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

  Widget _buildSlider(
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              Text(
                "${(value * 100).toInt()}%",
                style: TextStyle(
                  color: _primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              activeTrackColor: _primaryPurple,
              inactiveTrackColor: Colors.grey[200],
              thumbColor: const Color(0xFF9F75F9),
              overlayColor: _primaryPurple.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCard(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryPurple : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? _primaryPurple : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, IconData icon) {
    bool isSelected = _selectedInterests.contains(label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(label);
          } else {
            _selectedInterests.add(label);
          }
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryPurple : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryPurple : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
