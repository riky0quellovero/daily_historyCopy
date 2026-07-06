import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


/// provide access to the locale settings and manages it
/// save preferences in local
/// notify listeners when a new locale is set
class LocaleProvider extends ChangeNotifier {
  // singleton setup
  static final LocaleProvider instance = LocaleProvider._internal();
  LocaleProvider._internal();

  static const _localeKey = 'selected_locale';

  //TODO: update supported lcoales
  static const _supportedLocales = [
    'en',
    'it',
    'fr',
    'zh',
    'de',
    'es',
    'pt',
  ];

  Locale _locale = _getSystemLocale();

  Locale get locale => _locale;

  /// get sys locale if supported else english
  static Locale _getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;

    if (_supportedLocales.contains(systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }

    return const Locale('en');
  }

  /// load saved locale and notify listeners
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);

    if (code != null && _supportedLocales.contains(code)) {
      _locale = Locale(code);
    }

    notifyListeners();
  }

  /// set new locale and notify listeners
  Future<void> setLocale(Locale locale) async {
    if (!_supportedLocales.contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localeKey,
      locale.languageCode,
    );
  }
}
