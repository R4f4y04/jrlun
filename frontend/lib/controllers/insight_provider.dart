import 'package:flutter/material.dart';
import 'package:frontend/models/insight_model.dart';
import 'package:frontend/services/insight_service.dart';

class InsightProvider extends ChangeNotifier {
  final dynamic _service;

  InsightProvider({dynamic service}) : _service = service ?? InsightService();

  InsightModel? _currentInsight;
  bool _isLoading = false;
  String? _error;

  InsightModel? get currentInsight => _currentInsight;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentInsight() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentInsight = await _service.getCurrentInsight();
    } catch (e) {
      _error = 'Could not load insights. Is the backend running?';
      debugPrint("Error fetching current insight: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
