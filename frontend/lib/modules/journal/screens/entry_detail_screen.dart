import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';

/// Full entry detail screen showing journal text, AI analysis, tags, and suggestions.
class EntryDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final score = entry.sentimentScore;
    final moodLabel = score > 0.3
        ? 'Happy'
        : score > 0
            ? 'Content'
            : score > -0.3
                ? 'Neutral'
                : score > -0.6
                    ? 'Sad'
                    : 'Distressed';
    final moodEmoji = score > 0.3
        ? '😊'
        : score > 0
            ? '🙂'
            : score > -0.3
                ? '😐'
                : score > -0.6
                    ? '😔'
                    : '😢';
    final moodColor = score > 0.2
        ? AppTheme.positive
        : score < -0.2
            ? AppTheme.negative
            : AppTheme.tertiary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMM d, yyyy  •  h:mm a').format(entry.createdAt),
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Journal Text ──────────────────────────
            GlassmorphicCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                entry.rawText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tags ──────────────────────────────────
            if (entry.tags.isNotEmpty || entry.triggers.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...entry.tags.map((t) => _TagChip(label: t, isTag: true)),
                  ...entry.triggers
                      .map((t) => _TagChip(label: t, isTag: false)),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // ── AI Summary ────────────────────────────
            GlassmorphicCard(
              glowBorder: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppTheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _generateSummary(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Detected Emotion ──────────────────────
            GlassmorphicCard(
              child: Row(
                children: [
                  Text(moodEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detected Emotion',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          moodLabel,
                          style: TextStyle(
                            color: moodColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sentiment score badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: moodColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: moodColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      score.toStringAsFixed(2),
                      style: TextStyle(
                        color: moodColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Suggestion ────────────────────────────
            GlassmorphicCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tips_and_updates_rounded,
                        color: AppTheme.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Step',
                          style: TextStyle(
                            color: AppTheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _generateSuggestion(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _generateSummary() {
    final tags = entry.tags.join(', ');
    final triggers = entry.triggers.join(', ');
    final score = entry.sentimentScore;

    if (score > 0.3) {
      return 'This was a positive entry${tags.isNotEmpty ? ' related to $tags' : ''}. '
          '${triggers.isNotEmpty ? 'Key factors: $triggers. ' : ''}'
          'The overall tone suggests a good mental state.';
    } else if (score > -0.3) {
      return 'A balanced entry${tags.isNotEmpty ? ' touching on $tags' : ''}. '
          '${triggers.isNotEmpty ? 'Notable elements: $triggers. ' : ''}'
          'The sentiment is neutral, reflecting a stable day.';
    } else {
      return 'This entry shows some difficulty${tags.isNotEmpty ? ' around $tags' : ''}. '
          '${triggers.isNotEmpty ? 'Possible triggers: $triggers. ' : ''}'
          'Consider reaching out or taking a moment for self-care.';
    }
  }

  String _generateSuggestion() {
    final score = entry.sentimentScore;
    if (score > 0.3) {
      return 'Keep maintaining this balance. Consider planning tomorrow early to stay ahead!';
    } else if (score > -0.3) {
      return 'Try to build on today\'s stability. A short walk or mindful moment could boost your mood.';
    } else {
      return 'Be gentle with yourself today. Consider a calming activity or talking to someone you trust.';
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isTag;
  const _TagChip({required this.label, required this.isTag});

  @override
  Widget build(BuildContext context) {
    final color = isTag ? AppTheme.primary : AppTheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTag ? Icons.tag_rounded : Icons.bolt_rounded,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
