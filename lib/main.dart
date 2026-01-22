// lib/main.dart
import 'package:flutter/material.dart';
import 'package:yauctor_ai/core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aeuxnfamdwegompaqsdr.supabase.co',
    anonKey: 'sb_publishable_lOCc-Delx6ikV97blF3gJw_zmpiRaGj',
  );

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
