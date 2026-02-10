// ignore_for_file: deprecated_member_use, duplicate_ignore, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // Для ImageFilter
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// CONSTANTS & THEME
// -----------------------------------------------------------------------------
abstract class AppColors {
  static const bgDark = Color(0xFF0A0A0F);
  static const cyan = Color(0xFF00E5FF);
  static const purple = Color(0xFFD500F9);
  static const green = Color(0xFF00E676);
  static const pink = Color(0xFFFF4081);
  static const blue = Color(0xFF2979FF);
}

// -----------------------------------------------------------------------------
// MODELS
// -----------------------------------------------------------------------------
class Particle {
  double x;
  double y;
  double opacity;
  double speedX;
  double speedY;

  Particle({
    required this.x,
    required this.y,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });
}

class SentimentTag {
  final String word;
  double x;
  double y;
  double size;
  double opacity;
  Offset velocity;

  SentimentTag({
    required this.word,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.velocity,
  });
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------
class DigitalTwinAvatarScreen extends StatefulWidget {
  const DigitalTwinAvatarScreen({super.key});

  @override
  State<DigitalTwinAvatarScreen> createState() =>
      _DigitalTwinAvatarScreenState();
}

class _DigitalTwinAvatarScreenState extends State<DigitalTwinAvatarScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _mainLoopController;
  late final AnimationController _pulseController;
  late final AnimationController _glowController;

  // Interaction State
  double _manualRotationY = 0.0;
  double _manualRotationX = 0.0;
  Offset? _touchPosition;

  // Real-time Simulation Data
  Timer? _dataTimer;
  final math.Random _rng = math.Random();

  // Data Notifiers (To avoid full screen rebuilds)
  final ValueNotifier<String> _currentMood = ValueNotifier("Optimistic");
  final ValueNotifier<Color> _moodColor = ValueNotifier(AppColors.cyan);
  final ValueNotifier<double> _moodIntensity = ValueNotifier(0.72);
  final ValueNotifier<List<double>> _emotionWave = ValueNotifier(
    List.filled(30, 0.5),
  );
  final ValueNotifier<List<double>> _brainActivity = ValueNotifier(
    List.filled(10, 0.0),
  );

  // Metrics
  String _lastDecision = "Creative Problem Solving";
  double _decisionTime = 0.4;
  double _processingPower = 87.5;
  double _memoryUsage = 63.2;
  double _learningRate = 2.2;
  double _progressValue = 0.0;
  double _neuralActivity = 92.1;

  // Particles & Sentiments
  List<Particle> _floatingParticles = [];
  List<SentimentTag> _sentiments = [];

  @override
  void initState() {
    super.initState();

    // 1. Unified Main Loop (Drives Rotation & Particles)
    _mainLoopController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // 2. Pulse Effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // 3. Glow Effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _initFloatingParticles();
    _initSentiments();
    _initBrainActivity();

    // 4. Data Simulation Timer (Every 2.5s)
    _dataTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) _updateSimulationData();
    });
  }

  void _initFloatingParticles() {
    _floatingParticles = List.generate(40, (index) {
      return Particle(
        x: _rng.nextDouble() * 400 - 200,
        y: _rng.nextDouble() * 400 - 200,
        opacity: 0.1 + _rng.nextDouble() * 0.4,
        speedX: _rng.nextDouble() * 0.5 - 0.25,
        speedY: _rng.nextDouble() * 0.5 - 0.25,
      );
    });
  }

  void _initBrainActivity() {
    _brainActivity.value = List.generate(
      10,
      (index) => _rng.nextDouble() * 100,
    );
  }

  void _initSentiments() {
    final words = [
      "Logic",
      "Analysis",
      "Chaos",
      "Focus",
      "Risk",
      "Data",
      "Core",
    ];
    _sentiments = words.map((w) {
      double angle = _rng.nextDouble() * math.pi * 2;
      double r = _rng.nextDouble() * 0.8;
      return SentimentTag(
        word: w,
        x: r * math.cos(angle),
        y: r * math.sin(angle),
        size: 8 + _rng.nextDouble() * 8,
        opacity: 0.4 + _rng.nextDouble() * 0.6,
        velocity: Offset(
          _rng.nextDouble() * 0.5 - 0.25,
          _rng.nextDouble() * 0.5 - 0.25,
        ),
      );
    }).toList();
  }

  void _updateSimulationData() {
    // This method now updates Notifiers or calls setState only for the panels

    // Mood Logic
    double moodRng = _rng.nextDouble();
    if (moodRng > 0.6) {
      _currentMood.value = "Optimistic";
      _moodColor.value = AppColors.cyan;
    } else if (moodRng > 0.3) {
      _currentMood.value = "Focused";
      _moodColor.value = AppColors.purple;
    } else {
      _currentMood.value = "Calculating";
      _moodColor.value = AppColors.green;
    }
    _moodIntensity.value = 0.6 + (_rng.nextDouble() * 0.39);

    // Wave Logic
    _emotionWave.value = List.generate(30, (i) {
      double base = math.sin(i * 0.5 + _rng.nextDouble() * 0.5) * 0.3;
      double noise = (_rng.nextDouble() - 0.5) * 0.4;
      return (0.5 + base + noise).clamp(0.1, 0.9);
    });

    // Sentiments Update
    for (var s in _sentiments) {
      s.opacity = 0.3 + _rng.nextDouble() * 0.7;
      s.size = 6 + _rng.nextDouble() * 10;
    }

    // Brain Activity Update
    List<double> currentBrain = List.from(_brainActivity.value);
    for (int i = 0; i < currentBrain.length; i++) {
      currentBrain[i] = (currentBrain[i] + _rng.nextDouble() * 20 - 10).clamp(
        0,
        100,
      );
    }
    _brainActivity.value = currentBrain;

    // Trigger UI update for panels (only set state for metrics variables)
    setState(() {
      _lastDecision = [
        "Pattern Analysis",
        "Route Optimization",
        "Memory Sync",
        "Security Check",
        "Neural Training",
        "Data Compression",
        "Error Correction",
      ][_rng.nextInt(7)];
      _decisionTime = 0.1 + _rng.nextDouble() * 0.5;
      _learningRate = 1.5 + _rng.nextDouble() * 2.5;
      _progressValue = _learningRate / 5.0;
      _processingPower = 80 + _rng.nextDouble() * 20;
      _memoryUsage = 50 + _rng.nextDouble() * 30;
      _neuralActivity = 85 + _rng.nextDouble() * 15;
    });
  }

  @override
  void dispose() {
    _mainLoopController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _dataTimer?.cancel();
    _currentMood.dispose();
    _moodColor.dispose();
    _moodIntensity.dispose();
    _emotionWave.dispose();
    _brainActivity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // 1. Static Background (RepaintBoundary for performance)
          RepaintBoundary(
            child: CustomPaint(
              painter: _BackgroundPainter(),
              size: Size.infinite,
            ),
          ),

          // 2. Floating Particles (AnimatedBuilder handles frame updates)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _mainLoopController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ParticlePainter(
                      particles: _floatingParticles,
                      animationValue: _mainLoopController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Central Interactive Brain
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _manualRotationY += details.delta.dx * 0.01;
                  _manualRotationX -= details.delta.dy * 0.01;
                  _touchPosition = details.localPosition;
                });
              },
              onPanEnd: (_) => setState(() => _touchPosition = null),
              child: Container(
                color: Colors.transparent, // Hit test target
                child: Center(
                  child: ValueListenableBuilder<Color>(
                    valueListenable: _moodColor,
                    builder: (context, color, _) {
                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _mainLoopController,
                          _pulseController,
                          _glowController,
                        ]),
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(
                              isSmallScreen ? 250 : 300,
                              isSmallScreen ? 250 : 300,
                            ),
                            painter: _DigitalBrainPainter(
                              rotationY:
                                  (_mainLoopController.value * math.pi * 2) +
                                  _manualRotationY,
                              rotationX: _manualRotationX,
                              pulse: _pulseController.value,
                              primaryColor: color,
                              touchPosition: _touchPosition,
                              brainActivity: _brainActivity.value,
                              glowValue: _glowController.value,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 4. PANELS
          // Top Left: Emotions
          Positioned(
            top: 70,
            left: 16,
            child: _GlassPanel(
              width: isSmallScreen ? 150 : 160,
              height: isSmallScreen ? 160 : 180,
              child: ValueListenableBuilder<List<double>>(
                valueListenable: _emotionWave,
                builder: (context, wave, _) {
                  return _EmotionsPanel(
                    emotionWave: wave,
                    currentMood: _currentMood.value,
                    moodIntensity: _moodIntensity.value,
                    moodColor: _moodColor.value,
                    brainActivity: _brainActivity.value,
                    isSmallScreen: isSmallScreen,
                  );
                },
              ),
            ),
          ),

          // Top Right: Sentiments
          Positioned(
            top: 70,
            right: 16,
            child: _GlassPanel(
              width: isSmallScreen ? 150 : 160,
              height: isSmallScreen ? 160 : 180,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return _SentimentsPanel(
                    sentiments: _sentiments,
                    glowValue: _glowController.value,
                    isSmallScreen: isSmallScreen,
                  );
                },
              ),
            ),
          ),

          // Bottom Left: Decisions
          Positioned(
            bottom: 70,
            left: 16,
            child: _GlassPanel(
              width: isSmallScreen ? 150 : 160,
              height: isSmallScreen ? 160 : 180,
              child: _DecisionsPanel(
                lastDecision: _lastDecision,
                decisionTime: _decisionTime,
                processingPower: _processingPower,
                memoryUsage: _memoryUsage,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ),

          // Bottom Right: Learning
          Positioned(
            bottom: 70,
            right: 16,
            child: _GlassPanel(
              width: isSmallScreen ? 150 : 160,
              height: isSmallScreen ? 160 : 180,
              child: ValueListenableBuilder<Color>(
                valueListenable: _moodColor,
                builder: (context, color, _) {
                  return _LearningPanel(
                    learningRate: _learningRate,
                    progressValue: _progressValue,
                    neuralActivity: _neuralActivity,
                    color: color,
                    isSmallScreen: isSmallScreen,
                  );
                },
              ),
            ),
          ),

          // 5. Status Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: _StatusHeader(
                currentMood: _currentMood,
                moodColor: _moodColor,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ),

          // 6. Bottom Controls
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _BottomControls(
              moodColor: _moodColor,
              isSmallScreen: isSmallScreen,
              onRefresh: _updateSimulationData,
              onPause: () {
                if (_mainLoopController.isAnimating) {
                  _mainLoopController.stop();
                } else {
                  _mainLoopController.repeat();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS
// -----------------------------------------------------------------------------

class _StatusHeader extends StatelessWidget {
  final ValueNotifier<String> currentMood;
  final ValueNotifier<Color> moodColor;
  final bool isSmallScreen;

  const _StatusHeader({
    required this.currentMood,
    required this.moodColor,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ValueListenableBuilder<Color>(
        valueListenable: moodColor,
        builder: (context, color, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
                  ],
                ),
              ),
              Text(
                "DIGITAL TWIN ACTIVE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 11 : 12,
                  fontFamily: 'Courier',
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<String>(
                valueListenable: currentMood,
                builder: (context, mood, _) {
                  return Text(
                    mood.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: isSmallScreen ? 10 : 11,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final ValueNotifier<Color> moodColor;
  final bool isSmallScreen;
  final VoidCallback onRefresh;
  final VoidCallback onPause;

  const _BottomControls({
    required this.moodColor,
    required this.isSmallScreen,
    required this.onRefresh,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: moodColor,
      builder: (context, color, _) {
        final btnSize = isSmallScreen ? 32.0 : 36.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _ControlButton(
                    icon: Icons.refresh,
                    onTap: onRefresh,
                    color: color,
                    size: btnSize,
                  ),
                  const SizedBox(width: 8),
                  _ControlButton(
                    icon: Icons.pause,
                    onTap: onPause,
                    color: color,
                    size: btnSize,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      DateTime.now().toString().substring(11, 19),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'Courier',
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  _ControlButton(
                    icon: Icons.settings,
                    onTap: () {},
                    color: color,
                    size: btnSize,
                  ),
                  const SizedBox(width: 8),
                  _ControlButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                    color: color,
                    size: btnSize,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const _GlassPanel({required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      // Removed heavy BoxShadow and BackdropFilter for better FPS in panels
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: size * 0.5, color: Colors.white),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANEL CONTENTS
// -----------------------------------------------------------------------------

class _EmotionsPanel extends StatelessWidget {
  final List<double> emotionWave;
  final String currentMood;
  final double moodIntensity;
  final Color moodColor;
  final List<double> brainActivity;
  final bool isSmallScreen;

  const _EmotionsPanel({
    required this.emotionWave,
    required this.currentMood,
    required this.moodIntensity,
    required this.moodColor,
    required this.brainActivity,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelHeader(
          color: moodColor,
          text: "EMOTIONAL STATE",
          isSmall: isSmallScreen,
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: _WaveformPainter(data: emotionWave, color: moodColor),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currentMood,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${(moodIntensity * 100).toInt()}% intensity",
          style: TextStyle(
            color: moodColor,
            fontSize: isSmallScreen ? 9 : 10,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 8,
          child: Row(
            children: brainActivity.map((value) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: moodColor.withOpacity(value / 150),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SentimentsPanel extends StatelessWidget {
  final List<SentimentTag> sentiments;
  final double glowValue;
  final bool isSmallScreen;

  const _SentimentsPanel({
    required this.sentiments,
    required this.glowValue,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelHeader(
          color: AppColors.pink,
          text: "NEURAL PATTERNS",
          isSmall: true,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final center = Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight / 2,
              );
              return Stack(
                children: sentiments.map((tag) {
                  // Determine position inside box
                  final dx = center.dx + tag.x * (constraints.maxWidth / 2.2);
                  final dy = center.dy + tag.y * (constraints.maxHeight / 2.2);

                  return Positioned(
                    left: dx,
                    top: dy,
                    child: Opacity(
                      opacity: tag.opacity,
                      child: Text(
                        tag.word,
                        style: TextStyle(
                          color: AppColors.pink,
                          fontSize: tag.size * (isSmallScreen ? 0.8 : 1.0),
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DecisionsPanel extends StatelessWidget {
  final String lastDecision;
  final double decisionTime;
  final double processingPower;
  final double memoryUsage;
  final bool isSmallScreen;

  const _DecisionsPanel({
    required this.lastDecision,
    required this.decisionTime,
    required this.processingPower,
    required this.memoryUsage,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelHeader(
          color: AppColors.blue,
          text: "COGNITIVE METRICS",
          isSmall: true,
        ),
        const SizedBox(height: 8),
        Text(
          "Latest Decision",
          style: TextStyle(
            color: Colors.white54,
            fontSize: isSmallScreen ? 9 : 10,
          ),
        ),
        Text(
          lastDecision,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 11 : 12,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MetricIndicator(
              label: "Processing",
              value: processingPower,
              color: AppColors.blue,
              isSmall: isSmallScreen,
            ),
            _MetricIndicator(
              label: "Memory",
              value: memoryUsage,
              color: Colors.lightBlueAccent,
              isSmall: isSmallScreen,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Response: ${decisionTime.toStringAsFixed(1)}s",
          style: TextStyle(
            color: Colors.white30,
            fontSize: isSmallScreen ? 8 : 9,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}

class _LearningPanel extends StatelessWidget {
  final double learningRate;
  final double progressValue;
  final double neuralActivity;
  final Color color;
  final bool isSmallScreen;

  const _LearningPanel({
    required this.learningRate,
    required this.progressValue,
    required this.neuralActivity,
    required this.color,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelHeader(
          color: color,
          text: "LEARNING SYSTEM",
          isSmall: isSmallScreen,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _GaugePainter(percent: progressValue, color: color),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${learningRate.toStringAsFixed(1)}x",
                      style: TextStyle(
                        color: color,
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Learning Rate",
                      style: TextStyle(color: Colors.white54, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.white10,
          color: color,
          minHeight: 3,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSmall;

  const _PanelHeader({
    required this.color,
    required this.text,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isSmall ? 8 : 9,
            fontFamily: 'Courier',
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isSmall;

  const _MetricIndicator({
    required this.label,
    required this.value,
    required this.color,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white54, fontSize: isSmall ? 8 : 9),
        ),
        const SizedBox(height: 2),
        Text(
          "${value.toInt()}%",
          style: TextStyle(
            color: color,
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// OPTIMIZED PAINTERS
// -----------------------------------------------------------------------------

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.bgDark, const Color(0xFF0F0F1A), AppColors.bgDark],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = gradient);

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    double gridSize = 40;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue; // Used to trigger repaint

  _ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    for (final particle in particles) {
      // Simulate movement based on time in the painter or updated logic
      // Here we just draw them. Logic should update particle properties if needed
      // or we simulate basic movement here visually.

      // Update position cyclically based on animationValue to avoid altering state in paint
      double moveX =
          particle.x +
          (particle.speedX * 100 * animationValue).remainder(400) -
          200;
      double moveY =
          particle.y +
          (particle.speedY * 100 * animationValue).remainder(400) -
          200;

      // Wrap around logic visual only
      if (moveX < -200) moveX += 400;
      if (moveY < -200) moveY += 400;

      final position = Offset(center.dx + moveX, center.dy + moveY);
      final distance = (Offset(moveX, moveY)).distance;
      final opacity = (1 - distance / 250).clamp(0.0, particle.opacity);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(position, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _DigitalBrainPainter extends CustomPainter {
  final double rotationY;
  final double rotationX;
  final double pulse;
  final Color primaryColor;
  final Offset? touchPosition;
  final List<double> brainActivity;
  final double glowValue;

  _DigitalBrainPainter({
    required this.rotationY,
    required this.rotationX,
    required this.pulse,
    required this.primaryColor,
    this.touchPosition,
    required this.brainActivity,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radiusBase = size.width / 3;

    // Outer Glow
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.1 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, size.width / 2, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw Nodes & Connections
    for (int i = 0; i < 40; i++) {
      double angle = i * math.pi * 2 / 40;
      double r = radiusBase + math.sin(angle * 3 + pulse * 2) * 5;

      // 3D Projection math
      double x = r * math.cos(angle + rotationY);
      double y = r * math.sin(angle + rotationY);
      double z = r * math.sin(angle * 2);

      // Apply X rotation
      double yFinal = y * math.cos(rotationX) - z * math.sin(rotationX);

      Offset pos = Offset(center.dx + x, center.dy + yFinal);

      // Node
      linePaint.color = primaryColor.withOpacity(0.6 + 0.4 * math.sin(i).abs());
      linePaint.strokeWidth = 2;
      canvas.drawPoints(PointMode.points, [pos], linePaint);

      // Connections
      if (i % 2 == 0) {
        linePaint.strokeWidth = 0.5;
        linePaint.color = primaryColor.withOpacity(0.2);
        canvas.drawLine(center, pos, linePaint);
      }
    }

    // Draw Brain Activity Bars (Visualized as an inner ring)
    for (int i = 0; i < brainActivity.length; i++) {
      double angle = (i / brainActivity.length) * math.pi * 2 + rotationY;
      double value = brainActivity[i] / 100;

      double rInner = radiusBase * 0.5;
      double rOuter = rInner + (value * 20);

      Offset p1 = Offset(
        center.dx + rInner * math.cos(angle),
        center.dy + rInner * math.sin(angle),
      );
      Offset p2 = Offset(
        center.dx + rOuter * math.cos(angle),
        center.dy + rOuter * math.sin(angle),
      );

      linePaint.color = primaryColor.withOpacity(0.8);
      linePaint.strokeWidth = 2;
      canvas.drawLine(p1, p2, linePaint);
    }

    if (touchPosition != null) {
      canvas.drawCircle(
        touchPosition!,
        20,
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DigitalBrainPainter old) {
    return old.rotationY != rotationY ||
        old.rotationX != rotationX ||
        old.pulse != pulse ||
        old.glowValue != glowValue ||
        old.primaryColor != primaryColor;
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _WaveformPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height / 2 + (data[i] - 0.5) * size.height * 0.8;
      if (i == 0)
        path.moveTo(x, y);
      else {
        double prevX = (i - 1) * stepX;
        double prevY =
            size.height / 2 + (data[i - 1] - 0.5) * size.height * 0.8;
        path.cubicTo(prevX + stepX / 2, prevY, x - stepX / 2, y, x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.data != data || old.color != color;
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;

  _GaugePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.percent != percent || old.color != color;
}
