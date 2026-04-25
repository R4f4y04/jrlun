import 'package:flutter/material.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/services/journal_service.dart';

class JournalProvider extends ChangeNotifier {
  final dynamic _service;

  JournalProvider({dynamic service}) : _service = service ?? JournalService();

  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _service.getHistoricalEntries();
    } catch (e) {
      _error = 'Could not load entries. Is the backend running?';
      debugPrint("Error fetching entries: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEntry = await _service.submitEntry(text);
      _entries.insert(0, newEntry);
    } catch (e) {
      _error = 'Could not save entry. Please try again.';
      debugPrint("Error submitting entry: $e");
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
