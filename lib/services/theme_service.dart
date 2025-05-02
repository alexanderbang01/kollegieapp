import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  final String key = "is_dark_mode";
  late SharedPreferences _prefs;
  late bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _isDarkMode = false;
    _loadFromPrefs();
  }

  // Initialiserer SharedPreferences
  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Indlæser temavalg fra SharedPreferences
  _loadFromPrefs() async {
    await _initPrefs();
    _isDarkMode = _prefs.getBool(key) ?? false;
    notifyListeners();
  }

  // Gemmer temavalg til SharedPreferences
  _saveToPrefs() async {
    await _initPrefs();
    _prefs.setBool(key, _isDarkMode);
  }

  // Skifter mellem lyst og mørkt tema
  toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  // Sætter specifikt tema
  setTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }
}
