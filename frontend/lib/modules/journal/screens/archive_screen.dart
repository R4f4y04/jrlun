import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/controllers/journal_provider.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/glassmorphic_card.dart';
import 'package:frontend/modules/journal/screens/entry_detail_screen.dart';

/// Journal archive screen with week calendar and chronological entry list.
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Archive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, _) {
          final entries = provider.entries;
          return Column(
            children: [
              // ── Week Calendar ───────────────────────
              _WeekCalendar(entries: entries),
              const SizedBox(height: 8),
              // ── Entry List ──────────────────────────
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text('No entries yet',
                            style: TextStyle(color: AppTheme.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: entries.length,
                        itemBuilder: (context, i) =>
                            _ArchiveEntry(entry: entries[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.pop(context), // go back to journal tab
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  final List<JournalEntry> entries;
  const _WeekCalendar({required this.entries});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Generate 7 days centered on today
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    // Dates that have entries
    final entryDates = entries
        .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
        .toSet();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(now),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) {
              final isToday = d.day == now.day &&
                  d.month == now.month &&
                  d.year == now.year;
              final hasEntry =
                  entryDates.contains(DateFormat('yyyy-MM-dd').format(d));
              return _DayChip(day: d, isToday: isToday, hasEntry: hasEntry);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool hasEntry;
  const _DayChip(
      {required this.day, required this.isToday, required this.hasEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.primary.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        children: [
          Text(
            DateFormat('E').format(day).substring(0, 2),
            style: TextStyle(
              color: isToday ? AppTheme.primary : AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${day.day}',
            style: TextStyle(
              color: isToday ? Colors.white : AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasEntry
                  ? AppTheme.primary
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveEntry extends StatelessWidget {
  final JournalEntry entry;
  const _ArchiveEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EntryDetailScreen(entry: entry),
          ),
        ),
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy  •  h:mm a')
                          .format(entry.createdAt),
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.rawText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
