import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/insight_provider.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/modules/dashboard/widgets/insight_card.dart';
import 'package:frontend/modules/dashboard/widgets/sentiment_chart.dart';
import 'package:frontend/modules/dashboard/widgets/journal_input_field.dart';
import 'package:frontend/modules/dashboard/widgets/historical_entries_feed.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().fetchCurrentInsight();
      context.read<JournalProvider>().fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('MindMirror'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<InsightProvider>(
                builder: (context, provider, child) {
                  return InsightCard(insight: provider.currentInsight);
                },
              ),
              Consumer<JournalProvider>(
                builder: (context, provider, child) {
                  if (provider.entries.isEmpty) return const SizedBox.shrink();
                  return SentimentChart(entries: provider.entries);
                },
              ),
              const SizedBox(height: 24),
              const JournalInputField(),
              const SizedBox(height: 32),
              Text(
                "Your Reflections",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Consumer<JournalProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.entries.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return HistoricalEntriesFeed(entries: provider.entries);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
