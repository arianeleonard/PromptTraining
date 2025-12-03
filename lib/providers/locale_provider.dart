import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Manages the current app locale (EN/FR) and notifies listeners on change.
class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  LocaleProvider({Locale? initial}) : _locale = initial ?? const Locale('en') {
    _init();
  }

  Locale get locale => _locale;

  /// Update the locale. Only 'en' and 'fr' are supported.
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    if (!['en', 'fr'].contains(locale.languageCode.toLowerCase())) return;
    _locale = locale;
    notifyListeners();
    _save();
  }

  void _init() {
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final code = prefs.getString('app_locale_v1');
        if (code != null && ['en', 'fr'].contains(code)) {
          _locale = Locale(code);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Failed to load locale: $e');
      }
    });
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale_v1', _locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }
}
