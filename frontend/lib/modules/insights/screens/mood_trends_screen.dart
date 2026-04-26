import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';
import 'package:frontend/modules/dashboard/widgets/sentiment_chart.dart';
import 'package:frontend/modules/insights/widgets/mood_donut_chart.dart';

/// Full mood trends analytics screen.
class MoodTrendsScreen extends StatelessWidget {
  const MoodTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, provider, _) {
        final entries = provider.entries;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Line Chart ──────────────────────────
              if (entries.isNotEmpty) SentimentChart(entries: entries),
              const SizedBox(height: 16),

              // ── Distribution ────────────────────────
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mood Distribution',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    MoodDonutChart(entries: entries),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Best Day ────────────────────────────
              _buildBestDayCard(context, entries),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBestDayCard(
      BuildContext context, List<JournalEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // Find highest scoring entry
    final best = entries.reduce(
        (a, b) => a.sentimentScore > b.sentimentScore ? a : b);
    final dayName = _dayName(best.createdAt.weekday);

    return GlassmorphicCard(
      glowBorder: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.emoji_events_rounded, color: AppTheme.tertiary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Best Day',
                    style: TextStyle(
                        color: AppTheme.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(dayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'You were most positive and productive.',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
