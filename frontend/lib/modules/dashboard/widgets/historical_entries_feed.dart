import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/journal_entry.dart';

class HistoricalEntriesFeed extends StatelessWidget {
  final List<JournalEntry> entries;

  const HistoricalEntriesFeed({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text("No entries yet. Start reflecting!"),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryCard(context, entry);
      },
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context);
    
    // Combine tags and triggers for chips
    final metadata = [...entry.tags, ...entry.triggers];

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM d, yyyy').format(entry.createdAt),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.rawText,
              style: theme.textTheme.bodyLarge,
            ),
            if (metadata.isNotEmpty) const SizedBox(height: 12),
            if (metadata.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: metadata.map((label) => Chip(
                  label: Text(label),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  labelStyle: theme.textTheme.labelSmall,
                  side: BorderSide.none,
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
