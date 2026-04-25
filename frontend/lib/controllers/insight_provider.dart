import 'package:flutter/material.dart';
import 'package:frontend/models/insight_model.dart';
import 'package:frontend/services/mock_insight_service.dart';

class InsightProvider extends ChangeNotifier {
  final MockInsightService _service = MockInsightService();

  InsightModel? _currentInsight;
  bool _isLoading = false;

  InsightModel? get currentInsight => _currentInsight;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentInsight() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentInsight = await _service.getCurrentInsight();
    } catch (e) {
      debugPrint("Error fetching current insight: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
