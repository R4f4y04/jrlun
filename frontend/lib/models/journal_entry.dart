class JournalEntry {
  final String id;
  final String userId;
  final String rawText;
  final double sentimentScore;
  final List<String> tags;
  final List<String> triggers;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.rawText,
    required this.sentimentScore,
    required this.tags,
    required this.triggers,
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    // Handle potentially malformed dates like "2026-04-24T19:58:53.760202+00:00Z"
    String dateStr = json['created_at'] as String;
    if (dateStr.endsWith('+00:00Z')) {
      dateStr = dateStr.replaceAll('+00:00Z', 'Z');
    }
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rawText: json['raw_text'] as String,
      sentimentScore: (json['sentiment_score'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      triggers: List<String>.from(json['triggers'] ?? []),
      createdAt: DateTime.parse(dateStr),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'raw_text': rawText,
      'sentiment_score': sentimentScore,
      'tags': tags,
      'triggers': triggers,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
