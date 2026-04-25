import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/controllers/insight_provider.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/modules/dashboard/screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
      ],
      child: const MindMirrorApp(),
    ),
  );
}

class MindMirrorApp extends StatelessWidget {
  const MindMirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindMirror',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
