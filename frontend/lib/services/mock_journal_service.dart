import 'package:frontend/models/journal_entry.dart';

class MockJournalService {
  Future<List<JournalEntry>> getHistoricalEntries({int limit = 10, int offset = 0}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency

    return [
      JournalEntry(
        id: "1",
        userId: "user-123",
        rawText: "I'm exhausted from studying. Didn't sleep much.",
        sentimentScore: -0.4,
        tags: ["studying", "tired"],
        triggers: ["lack of sleep", "academic pressure"],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        id: "2",
        userId: "user-123",
        rawText: "Had a great workout today. Feeling energized!",
        sentimentScore: 0.8,
        tags: ["gym", "happy"],
        triggers: ["exercise"],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<JournalEntry> submitEntry(String rawText) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    return JournalEntry(
      id: "3",
      userId: "user-123",
      rawText: rawText,
      sentimentScore: 0.0, // Mock score
      tags: ["mock_tag"],
      triggers: ["mock_trigger"],
      createdAt: DateTime.now(),
    );
  }
}
