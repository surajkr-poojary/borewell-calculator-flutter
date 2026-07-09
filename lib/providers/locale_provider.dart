import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's chosen app language and persists it across launches.
/// A null [locale] means "follow the system language" (falling back to
/// English if the system language isn't one we support).
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale_v1';
  static const supportedLocales = [Locale('en'), Locale('kn')];

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      _locale = supportedLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => supportedLocales.first,
      );
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
