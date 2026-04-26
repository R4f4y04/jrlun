import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';
import 'package:frontend/modules/journal/screens/entry_detail_screen.dart';

class HistoricalEntriesFeed extends StatelessWidget {
  final List<JournalEntry> entries;
  const HistoricalEntriesFeed({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.book_outlined, color: AppTheme.textMuted, size: 40),
              const SizedBox(height: 12),
              Text(
                'No entries yet. Start reflecting!',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) => _buildEntryCard(context, entries[index]),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final score = entry.sentimentScore;
    final emoji = score > 0.3
        ? '😊'
        : score > 0
            ? '🙂'
            : score > -0.3
                ? '😐'
                : score > -0.6
                    ? '😔'
                    : '😢';
    final metadata = [...entry.tags, ...entry.triggers];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: entry)),
        ),
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.createdAt),
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.rawText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (metadata.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: metadata.take(4).map((label) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
