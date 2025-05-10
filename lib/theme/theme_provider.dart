// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemePreference(); // Load preference when provider is created
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themePrefKey);
      ThemeMode loadedTheme = ThemeMode.light; // Default to light

      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        loadedTheme = ThemeMode.values[themeIndex];
      }
      // Only update and notify if the theme actually changes from the initial _themeMode
      // or if it's the first load.
      if (_themeMode != loadedTheme) {
         _themeMode = loadedTheme;
         notifyListeners();
      } else {
        // If loaded theme is same as initial, ensure _themeMode is set, but no need to notify again
        _themeMode = loadedTheme;
      }
    } catch (e) {
      print("Error loading theme preference: $e");
      // Keep current _themeMode (which is the default ThemeMode.light)
      // Optionally, notify if you want to ensure UI reflects this default after an error
      // notifyListeners();
    }
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themePrefKey, mode.index);
    } catch (e) {
      print("Error saving theme preference: $e");
    }
  }

  void toggleTheme(bool darkModeOn) {
    _themeMode = darkModeOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }

  // Optional: If you want to support system theme
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }
}