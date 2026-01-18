// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:yauctor_ai/ui/layout/main_layout.dart';
import '../../features/simulation/simulation_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/digital_twin/digital_twin_screen.dart';
import '../../features/your_state/your_state_screen.dart';
import '../../features/onboarding/welcome_questionnaire_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String simulation = '/simulation';
  static const String analytics = '/analytics';
  static const String assistant = '/assistant';
  static const String profile = '/profile';
  static const String digitalTwin = '/digital-twin';
  static const String yourState = '/your-state';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const WelcomeQuestionnaireScreen(),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const MainLayout());
      case simulation:
        return MaterialPageRoute(builder: (_) => const SimulationScreen());
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case assistant:
        return MaterialPageRoute(builder: (_) => const AssistantScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case digitalTwin:
        return MaterialPageRoute(builder: (_) => const DigitalTwinScreen());
      case yourState:
        return MaterialPageRoute(builder: (_) => const YourStateScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static void goToSimulation(BuildContext context, {bool runNew = false}) {
    Navigator.pushNamed(context, simulation);
  }

  static void goToAnalytics(BuildContext context) {
    Navigator.pushNamed(context, analytics);
  }

  static void goToAssistant(BuildContext context) {
    Navigator.pushNamed(context, assistant);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
