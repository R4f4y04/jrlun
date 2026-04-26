import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/insight_provider.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/controllers/user_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';
import 'package:frontend/core/widgets/shimmer_loader.dart';
import 'package:frontend/core/widgets/error_card.dart';
import 'package:frontend/modules/dashboard/widgets/insight_card.dart';
import 'package:frontend/modules/dashboard/widgets/sentiment_chart.dart';
import 'package:frontend/modules/dashboard/widgets/historical_entries_feed.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _insightRefreshTimer;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

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
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: () async {
          await Future.wait([
            context.read<InsightProvider>().fetchCurrentInsight(),
            context.read<JournalProvider>().fetchEntries(),
          ]);
        },
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          return Text(
                            '$_greeting, ${userProvider.name} ✨',
                            style: Theme.of(context).textTheme.headlineMedium,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Here's your daily overview",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Summary Card ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Consumer<JournalProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.entries.isEmpty) {
                        return const ShimmerLoader(height: 130);
                      }
                      return _buildSummaryCard(context, provider);
                    },
                  ),
                ),
              ),

              // ── Quick Stats ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Consumer<JournalProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.entries.isEmpty) {
                        return Row(
                          children: List.generate(
                            3,
                            (i) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: i == 0 ? 0 : 6,
                                  right: i == 2 ? 0 : 6,
                                ),
                                child: const ShimmerLoader(height: 80),
                              ),
                            ),
                          ),
                        );
                      }
                      return _buildQuickStats(context, provider);
                    },
                  ),
                ),
              ),

              // ── Insight Card ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Consumer<InsightProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null) {
                        return ErrorCard(
                          message: provider.error!,
                          onRetry: () => provider.fetchCurrentInsight(),
                        );
                      }
                      if (provider.isLoading && provider.currentInsight == null) {
                        return const ShimmerLoader(height: 140);
                      }
                      return InsightCard(insight: provider.currentInsight);
                    },
                  ),
                ),
              ),

              // ── Sentiment Chart ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Consumer<JournalProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null && provider.entries.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (provider.isLoading && provider.entries.isEmpty) {
                        return const ShimmerLoader(height: 260);
                      }
                      if (provider.entries.isEmpty) return const SizedBox.shrink();
                      return SentimentChart(entries: provider.entries);
                    },
                  ),
                ),
              ),

              // ── Error banner ────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<JournalProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: ErrorCard(
                          message: provider.error!,
                          onRetry: () => provider.fetchEntries(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // ── Section Title ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Reflections',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Recent',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Historical Entries ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<JournalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.entries.isEmpty) {
                        return Column(
                          children: List.generate(
                            3,
                            (_) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: ShimmerLoader(height: 100),
                            ),
                          ),
                        );
                      }
                      return HistoricalEntriesFeed(entries: provider.entries);
                    },
                  ),
                ),
              ),

              // ── Bottom padding ──────────────────────────
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, JournalProvider provider) {
    final entries = provider.entries;
    if (entries.isEmpty) {
      return GlassmorphicCard(
        glowBorder: true,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Journaling',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Write your first entry to unlock AI-powered insights about yourself.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.3),
                    AppTheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Center(
                child: Text('✍️', style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
      );
    }

    // Compute today's mood from entries
    final todayEntries = entries.where((e) {
      final now = DateTime.now();
      return e.createdAt.year == now.year &&
          e.createdAt.month == now.month &&
          e.createdAt.day == now.day;
    }).toList();

    final avgScore = todayEntries.isEmpty
        ? entries.first.sentimentScore
        : todayEntries.map((e) => e.sentimentScore).reduce((a, b) => a + b) /
            todayEntries.length;

    final moodEmoji = avgScore > 0.3
        ? '😊'
        : avgScore > 0
            ? '🙂'
            : avgScore > -0.3
                ? '😐'
                : avgScore > -0.6
                    ? '😔'
                    : '😢';

    final moodLabel = avgScore > 0.3
        ? 'Great'
        : avgScore > 0
            ? 'Good'
            : avgScore > -0.3
                ? 'Okay'
                : avgScore > -0.6
                    ? 'Bad'
                    : 'Very Bad';

    return GlassmorphicCard(
      glowBorder: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Summary",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You felt $moodLabel $moodEmoji',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  todayEntries.isEmpty
                      ? 'Your latest entry shows a ${moodLabel.toLowerCase()} mood.'
                      : '${todayEntries.length} ${todayEntries.length == 1 ? 'entry' : 'entries'} today with ${moodLabel.toLowerCase()} overall sentiment.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Glowing orb
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.4),
                  AppTheme.primary.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(moodEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, JournalProvider provider) {
    final entries = provider.entries;
    final entryCount = entries.length;

    // Compute average score
    double avgScore = 0;
    if (entries.isNotEmpty) {
      avgScore = entries.map((e) => e.sentimentScore).reduce((a, b) => a + b) /
          entries.length;
    }
    final avgLabel = avgScore > 0.3
        ? 'Great'
        : avgScore > 0
            ? 'Good'
            : avgScore > -0.3
                ? 'Okay'
                : 'Low';

    return Row(
      children: [
        _QuickStatTile(
          icon: Icons.favorite_rounded,
          label: 'Mood',
          value: avgLabel,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 12),
        _QuickStatTile(
          icon: Icons.book_rounded,
          label: 'Entries',
          value: '$entryCount',
          color: AppTheme.secondary,
        ),
        const SizedBox(width: 12),
        _QuickStatTile(
          icon: Icons.local_fire_department_rounded,
          label: 'Streak',
          value: '7 days',
          color: AppTheme.tertiary,
        ),
      ],
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
