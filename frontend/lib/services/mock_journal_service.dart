import 'package:frontend/models/journal_entry.dart';

/// Mock journal service with 10 realistic entries spanning a week.
///
/// Used as a fallback when the backend is unavailable.
/// DO NOT DELETE — this is the demo safety net.
class MockJournalService {
  Future<List<JournalEntry>> getHistoricalEntries({int limit = 10, int offset = 0}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      JournalEntry(
        id: "1",
        userId: "user-123",
        rawText: "I'm exhausted from studying. Didn't sleep much last night and I can feel it in everything I do.",
        sentimentScore: -0.4,
        tags: ["studying", "tired", "fatigue"],
        triggers: ["lack of sleep", "academic pressure"],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        id: "2",
        userId: "user-123",
        rawText: "Had a great workout today. Feeling energized and motivated!",
        sentimentScore: 0.8,
        tags: ["gym", "happy", "energetic"],
        triggers: ["exercise"],
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
      ),
      JournalEntry(
        id: "3",
        userId: "user-123",
        rawText: "Productive day at work. Got through most of my task list and even had time for coffee with a friend.",
        sentimentScore: 0.6,
        tags: ["productive", "social"],
        triggers: [],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      JournalEntry(
        id: "4",
        userId: "user-123",
        rawText: "Couldn't sleep again. Only got about 4 hours. Feeling drained and unfocused.",
        sentimentScore: -0.7,
        tags: ["tired", "insomnia", "brain-fog"],
        triggers: ["lack of sleep"],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      JournalEntry(
        id: "5",
        userId: "user-123",
        rawText: "Feeling a bit stressed about the upcoming presentation, but I think I am prepared.",
        sentimentScore: 0.1,
        tags: ["work", "stress", "presentation"],
        triggers: ["academic pressure"],
        createdAt: now.subtract(const Duration(days: 3, hours: 6)),
      ),
      JournalEntry(
        id: "6",
        userId: "user-123",
        rawText: "Went for a long run this morning. The weather was perfect. My mood is way up.",
        sentimentScore: 0.9,
        tags: ["gym", "running", "happy"],
        triggers: ["exercise"],
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      JournalEntry(
        id: "7",
        userId: "user-123",
        rawText: "Had an argument with my roommate over chores. Feeling annoyed and frustrated.",
        sentimentScore: -0.5,
        tags: ["conflict", "frustrated"],
        triggers: ["interpersonal conflict"],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      JournalEntry(
        id: "8",
        userId: "user-123",
        rawText: "Slept well for once! 8 hours. Feeling refreshed and ready to tackle the day.",
        sentimentScore: 0.7,
        tags: ["rested", "energetic"],
        triggers: [],
        createdAt: now.subtract(const Duration(days: 5, hours: 12)),
      ),
      JournalEntry(
        id: "9",
        userId: "user-123",
        rawText: "Exam tomorrow and I don't feel prepared. Pulling an all-nighter. Lots of coffee.",
        sentimentScore: -0.6,
        tags: ["studying", "anxious", "stressed"],
        triggers: ["academic pressure", "lack of sleep"],
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      JournalEntry(
        id: "10",
        userId: "user-123",
        rawText: "Enjoying a relaxing weekend. Cooked a nice meal and watched a movie. Feeling at peace.",
        sentimentScore: 0.75,
        tags: ["weekend", "relaxed", "cooking"],
        triggers: [],
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  Future<JournalEntry> submitEntry(String rawText) async {
    await Future.delayed(const Duration(seconds: 1));

    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: "user-123",
      rawText: rawText,
      sentimentScore: 0.0,
      tags: ["mock_tag"],
      triggers: ["mock_trigger"],
      createdAt: DateTime.now(),
    );
  }
}
