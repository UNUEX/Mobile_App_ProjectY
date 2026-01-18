// lib/main.dart
import 'package:flutter/material.dart';
import 'package:yauctor_ai/core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: YauctorApp()));
}

class YauctorApp extends StatelessWidget {
  const YauctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yauctor',
      theme: AppTheme.light(),
      initialRoute: AppRouter.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
