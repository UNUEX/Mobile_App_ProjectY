// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/simulation/simulation_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/digital_twin/digital_twin_screen.dart';
import '../../features/your_state/your_state_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String simulation = '/simulation';
  static const String analytics = '/analytics';
  static const String assistant = '/assistant';
  static const String profile = '/profile';
  static const String digitalTwin = '/digital-twin';
  static const String yourState = '/your-state';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
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

  // Методы для удобной навигации
  static void goToSimulation(BuildContext context) {
    Navigator.pushNamed(context, simulation);
  }

  static void goToAssistant(BuildContext context) {
    Navigator.pushNamed(context, assistant);
  }

  static void goToAnalytics(BuildContext context) {
    Navigator.pushNamed(context, analytics);
  }

  static void goToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goToDigitalTwin(BuildContext context) {
    Navigator.pushNamed(context, digitalTwin);
  }

  static void goToYourState(BuildContext context) {
    Navigator.pushNamed(context, yourState);
  }
}
