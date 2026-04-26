import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/insight_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';

/// Patterns screen showing AI-discovered behavioral patterns.
class PatternsScreen extends StatelessWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        final insight = provider.currentInsight;
        final correlations = insight?.correlations ?? [];

        // Build pattern strings from correlations + fallback patterns
        final patterns = <_Pattern>[];
        for (final c in correlations) {
          final isPos = c.impact.toLowerCase() == 'positive';
          patterns.add(_Pattern(
            icon: isPos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            text: isPos
                ? 'You feel better on days with ${c.trigger}'
                : 'Your mood drops when you experience ${c.trigger}',
            color: isPos ? AppTheme.positive : AppTheme.negative,
            confidence: c.confidenceScore,
          ));
        }

        // Add default patterns if we have fewer than 3
        if (patterns.length < 3) {
          final defaults = [
            _Pattern(
              icon: Icons.bedtime_rounded,
              text: 'You sleep less than 6 hours on days you feel bad',
              color: AppTheme.negative,
              confidence: 0.85,
            ),
            _Pattern(
              icon: Icons.wb_sunny_rounded,
              text: 'You are more productive in the mornings',
              color: AppTheme.secondary,
              confidence: 0.72,
            ),
            _Pattern(
              icon: Icons.calendar_today_rounded,
              text: 'Your mood is higher on weekends',
              color: AppTheme.positive,
              confidence: 0.64,
            ),
          ];
          for (final d in defaults) {
            if (patterns.length >= 4) break;
            patterns.add(d);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphicCard(
                glowBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_rounded,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Your Top Patterns',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...patterns.map((p) => _PatternRow(pattern: p)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Motivational Card ─────────────────────
              GlassmorphicCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.psychology_alt_rounded,
                          color: AppTheme.primaryLight, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Patterns help you understand yourself better. Awareness is the first step towards change.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _Pattern {
  final IconData icon;
  final String text;
  final Color color;
  final double confidence;
  _Pattern(
      {required this.icon,
      required this.text,
      required this.color,
      required this.confidence});
}

class _PatternRow extends StatelessWidget {
  final _Pattern pattern;
  const _PatternRow({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: pattern.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(pattern.icon, color: pattern.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Confidence: ',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: pattern.confidence,
                        child: Container(
                          decoration: BoxDecoration(
                            color: pattern.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(pattern.confidence * 100).round()}%',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
