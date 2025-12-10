import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme state and user theme preferences.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider({
    ThemeMode themeMode = ThemeMode.system,
  }) : _themeMode = themeMode {
    _init();
  }

  /// Current theme mode - drives MaterialApp.themeMode
  ThemeMode get themeMode => _themeMode;

  /// Cycles through theme modes: System → Light → Dark → System
  ///
  /// Called by the theme toggle button in the chat header.
  /// Provides a smooth user experience for theme switching without
  /// requiring separate controls for each mode.
  void toggleThemeMode() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
    _save();
  }

  /// Directly sets the theme mode to a specific value
  ///
  /// **Parameters:**
  /// - `themeMode`: Target theme mode
  ///
  /// **Usage:**
  /// ```dart
  /// // Set specific theme:
  /// themeProvider.setThemeMode(ThemeMode.dark);
  ///
  /// // Conditionally set theme:
  /// if (userPrefersDark) {
  ///   themeProvider.setThemeMode(ThemeMode.dark);
  /// }
  /// ```
  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();
      _save();
    }
  }

  // Legacy compatibility methods
  @Deprecated('Use themeMode instead')
  Brightness get brightness {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  @Deprecated('Use toggleThemeMode instead')
  void toggleBrightness() => toggleThemeMode();

  @Deprecated('Use setThemeMode instead')
  void setBrightness(Brightness brightness) {
    setThemeMode(
      brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void _init() {
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString('theme_mode_v1');
        switch (saved) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            return;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to load theme: $e');
      }
    });
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (_themeMode) {
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
      };
      await prefs.setString('theme_mode_v1', value);
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }
}
