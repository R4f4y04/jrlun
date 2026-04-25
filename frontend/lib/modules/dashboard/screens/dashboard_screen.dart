import 'dart:async';
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
  Timer? _insightRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().fetchCurrentInsight();
      context.read<JournalProvider>().fetchEntries();
    });

    // Periodic insight refresh every 60s to trigger AnimatedSwitcher cross-fade
    _insightRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        context.read<InsightProvider>().fetchCurrentInsight();
      }
    });
  }

  @override
  void dispose() {
    _insightRefreshTimer?.cancel();
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<InsightProvider>().fetchCurrentInsight(),
            context.read<JournalProvider>().fetchEntries(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Insight Card ---
                Consumer<InsightProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null) {
                      return _ErrorFallbackCard(
                        message: provider.error!,
                        onRetry: () => provider.fetchCurrentInsight(),
                      );
                    }
                    if (provider.isLoading && provider.currentInsight == null) {
                      return const _ShimmerCard(height: 140);
                    }
                    return InsightCard(insight: provider.currentInsight);
                  },
                ),

                // --- Sentiment Chart ---
                Consumer<JournalProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null && provider.entries.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (provider.isLoading && provider.entries.isEmpty) {
                      return const _ShimmerCard(height: 260);
                    }
                    if (provider.entries.isEmpty) return const SizedBox.shrink();
                    return SentimentChart(entries: provider.entries);
                  },
                ),
                const SizedBox(height: 24),

                // --- Journal Input ---
                const JournalInputField(),
                const SizedBox(height: 32),

                // --- Error banner (if entries failed) ---
                Consumer<JournalProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ErrorFallbackCard(
                          message: provider.error!,
                          onRetry: () => provider.fetchEntries(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Text(
                  "Your Reflections",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // --- Historical Entries ---
                Consumer<JournalProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.entries.isEmpty) {
                      return Column(
                        children: List.generate(
                          3,
                          (_) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: _ShimmerCard(height: 100),
                          ),
                        ),
                      );
                    }
                    return HistoricalEntriesFeed(entries: provider.entries);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error Fallback Card
// ---------------------------------------------------------------------------
class _ErrorFallbackCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorFallbackCard({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.error.withValues(alpha: 0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            if (onRetry != null)
              IconButton(
                icon: Icon(Icons.refresh, color: theme.colorScheme.error),
                onPressed: onRetry,
                tooltip: 'Retry',
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer Loading Skeleton
// ---------------------------------------------------------------------------
class _ShimmerCard extends StatefulWidget {
  final double height;

  const _ShimmerCard({required this.height});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final opacity = 0.08 + (_animation.value * 0.12);
        return Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: opacity * 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
