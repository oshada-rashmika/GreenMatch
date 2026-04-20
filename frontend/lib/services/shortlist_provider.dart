import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShortlistProvider extends ChangeNotifier {
  static const String _storageKey = 'shortlisted_projects';
  final Set<String> _shortlistedIds = {};

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  ShortlistProvider() {
    _loadShortlist();
  }

  Future<void> _loadShortlist() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_storageKey) ?? [];
    _shortlistedIds.addAll(savedList);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveShortlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _shortlistedIds.toList());
  }

  bool isShortlisted(String projectId) {
    return _shortlistedIds.contains(projectId);
  }

  Future<void> toggleShortlist(String projectId) async {
    if (_shortlistedIds.contains(projectId)) {
      _shortlistedIds.remove(projectId);
    } else {
      _shortlistedIds.add(projectId);
    }
    notifyListeners();
    await _saveShortlist();
  }

  Set<String> get shortlistedIds => Set.unmodifiable(_shortlistedIds);
}
