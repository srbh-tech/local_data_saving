import 'package:flutter/material.dart';
import 'shared_pref/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefsService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._prefsService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final isDark = await _prefsService.getDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _prefsService.saveDarkMode(isDark);
    notifyListeners();
  }
}
