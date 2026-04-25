class InsightCorrelation {
  final String trigger;
  final String impact;
  final double confidenceScore;

  InsightCorrelation({
    required this.trigger,
    required this.impact,
    required this.confidenceScore,
  });

  factory InsightCorrelation.fromJson(Map<String, dynamic> json) {
    return InsightCorrelation(
      trigger: json['trigger'] as String,
      impact: json['impact'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'impact': impact,
      'confidence_score': confidenceScore,
    };
  }
}

class InsightModel {
  final String id;
  final String userId;
  final String summary;
  final List<InsightCorrelation> correlations;
  final String suggestedAction;
  final DateTime generatedAt;

  InsightModel({
    required this.id,
    required this.userId,
    required this.summary,
    required this.correlations,
    required this.suggestedAction,
    required this.generatedAt,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      summary: json['summary'] as String,
      correlations: (json['correlations'] as List<dynamic>?)
              ?.map((e) => InsightCorrelation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suggestedAction: json['suggested_action'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'summary': summary,
      'correlations': correlations.map((e) => e.toJson()).toList(),
      'suggested_action': suggestedAction,
      'generated_at': generatedAt.toUtc().toIso8601String(),
    };
  }
}
