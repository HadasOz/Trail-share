import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/db_service.dart';
import '../services/prefs_service.dart';

class AppProvider extends ChangeNotifier {
  final _dbService = DbService();
  final _prefsService = PrefsService();

  List<Post> _favorites = [];
  bool _darkMode = false;
  double _fontSize = 14.0;
  String? _userId;
  String? _userName;

  List<Post> get favorites => _favorites;
  bool get darkMode => _darkMode;
  double get fontSize => _fontSize;
  String? get userId => _userId;
  String? get userName => _userName;

  Future<void> init(String uid, String name) async {
    _userId = uid;
    _userName = name;
    _darkMode = await _prefsService.getDarkMode();
    _fontSize = await _prefsService.getFontSize();
    await loadFavorites();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _favorites = await _dbService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Post post) async {
    final exists = await _dbService.isFavorite(post.id);
    if (exists) {
      await _dbService.removeFavorite(post.id);
    } else {
      await _dbService.addFavorite(post);
    }
    await loadFavorites();
  }

  bool isFavorite(String postId) => _favorites.any((p) => p.id == postId);

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _prefsService.setDarkMode(value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value;
    await _prefsService.setFontSize(value);
    notifyListeners();
  }

  void clear() {
    _userId = null;
    _userName = null;
    _favorites = [];
    notifyListeners();
  }
}
