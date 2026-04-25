import 'package:frontend/models/insight_model.dart';

class MockInsightService {
  Future<InsightModel> getCurrentInsight() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency

    return InsightModel(
      id: "insight-1",
      userId: "user-123",
      summary: "Your mood consistently drops on days with less than 6 hours of sleep.",
      correlations: [
        InsightCorrelation(
          trigger: "lack of sleep",
          impact: "negative",
          confidenceScore: 0.85,
        ),
      ],
      suggestedAction: "Consider adjusting your evening routine tonight to prioritize rest.",
      generatedAt: DateTime.now(),
    );
  }
}
