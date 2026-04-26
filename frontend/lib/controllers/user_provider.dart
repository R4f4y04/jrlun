import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Ahmed';

  String get name => _name;

  UserProvider() {
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    if (savedName != null && savedName.isNotEmpty) {
      _name = savedName;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    _name = newName.trim();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
  }
}
