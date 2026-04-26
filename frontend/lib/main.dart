import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/controllers/insight_provider.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/controllers/user_provider.dart';
import 'package:frontend/modules/splash/screens/splash_screen.dart';

// To fall back to mock services if the backend is down, uncomment these:
// import 'package:frontend/services/mock_journal_service.dart';
// import 'package:frontend/services/mock_insight_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Real services (default) — connect to FastAPI at localhost:8001
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Mock fallback — uncomment below and comment above to use mocks:
        // ChangeNotifierProvider(create: (_) => JournalProvider(service: MockJournalService())),
        // ChangeNotifierProvider(create: (_) => InsightProvider(service: MockInsightService())),
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
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
