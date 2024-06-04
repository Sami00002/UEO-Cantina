import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  final String key = "theme";
  late SharedPreferences _prefs;
  late bool _isDarkTheme;

  bool get isDarkTheme => _isDarkTheme;

  ThemeNotifier() {
    _isDarkTheme = false;
    _initPrefs();
  }

  toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkTheme = _prefs.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() {
    _prefs.setBool(key, _isDarkTheme);
  }
}