import 'package:flutter/material.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/services/mock_journal_service.dart';

class JournalProvider extends ChangeNotifier {
  final MockJournalService _service = MockJournalService();
  
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _service.getHistoricalEntries();
    } catch (e) {
      debugPrint("Error fetching entries: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(String text) async {
    if (text.trim().isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newEntry = await _service.submitEntry(text);
      _entries.insert(0, newEntry);
    } catch (e) {
      debugPrint("Error submitting entry: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
