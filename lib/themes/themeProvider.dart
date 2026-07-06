import 'package:flutter/material.dart';

//theme files
import 'package:daily_history/themes/darkTheme.dart';
import 'package:daily_history/themes/lightTheme.dart';

import 'package:shared_preferences/shared_preferences.dart';

///boolean enum indicating theme settings
enum SelectedTheme {
  dark(true),
  light(false);

  final bool value;
  const SelectedTheme(this.value);
}

//because of its lifecycle there is no necessity to remove the listeners

///manage the theme changing along the application.
///expose the current theme and save the preferences
///use [setTheme] to change the current theme
///listen to this widget for them updates
class ThemeProvider extends ChangeNotifier {
  // Singleton setup
  static final ThemeProvider instance = ThemeProvider._internal();
  ThemeProvider._internal();

  static const _themeKey = 'selected_theme';

  SelectedTheme _theme = SelectedTheme.light;
  SelectedTheme get theme => _theme;
  ThemeData get themeData => (_theme == SelectedTheme.dark) ? darkTheme : lightTheme;

  /// load the saved theme
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_themeKey);

    if (code != null && code.isNotEmpty) {
      _theme = SelectedTheme.values.byName(code);
      notifyListeners();
    }
  }

  /// set the theme (only update if the theme changed)
  Future<void> setTheme(SelectedTheme theme) async {
    if(theme == _theme) return;

    //set new value
    _theme = theme;
    notifyListeners();

    //save change in locale
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _theme.name);
  }

  /// set the theme (only update if the theme changed)
  Future<void> swapTheme() async {
    //set new value
    _theme = (_theme == SelectedTheme.light) ? SelectedTheme.dark : SelectedTheme.light;
    notifyListeners();

    //save change in locale
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _theme.name);
  }
}

extension ThemeExt on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

///text styles for the application
enum TextStyles {
  barTitle (TextStyle(fontFamily: 'abhaya', fontSize: 29)),
  title (TextStyle(fontFamily: 'abhaya', fontSize: 20)),
  figureName (TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w700, fontSize: 24)),
  tags (TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w700, fontSize: 9)),
  text (TextStyle(fontFamily: 'lora', fontSize: 16)),
  citSign(TextStyle(fontFamily: 'abhaya', fontSize: 10)),
  cit(TextStyle(fontFamily: 'playfair', fontSize: 16, fontStyle: FontStyle.italic)),
  review(TextStyle(fontFamily: 'lora', fontWeight: FontWeight.w600, fontSize: 20)),
  textTitle(TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w700, fontSize: 20)),
  share(TextStyle(fontFamily: 'lora', fontWeight: FontWeight.w600, fontSize: 13)),
  settingsButton(TextStyle(fontFamily: 'abhaya', fontSize: 16)),
  textBox(TextStyle(fontFamily: 'abhaya', fontSize: 16, color: Color.fromARGB(255, 169, 169, 169))),
  searchBar(TextStyle(fontFamily: 'arial', fontSize: 13, color: Color.fromARGB(255, 169, 169, 169))),
  research(TextStyle(fontFamily: 'arial', fontSize: 16)),
  day(TextStyle(fontFamily: 'abhaya', fontSize: 12)),
  dayNum(TextStyle(fontFamily: 'abhaya', fontSize: 13, color: Colors.white)),
  month(TextStyle(fontFamily: 'abhaya', fontSize: 22)),
  year(TextStyle(fontFamily: 'abhaya', fontSize: 22, color: Color.fromARGB(255, 169, 169, 169))),
  settingsTitle(TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w600, fontSize: 16)),
  settingsSubtitle(TextStyle(fontFamily: 'abhaya', fontSize: 14, color: Color.fromARGB(255, 169, 169, 169))),
  notificationTitle(TextStyle(fontFamily: 'abhaya', fontSize: 18)),
  language(TextStyle(fontFamily: 'arial', fontSize: 15)),
  timeButton(TextStyle(fontFamily: 'abhaya', fontSize: 17)),
  errorMsg(TextStyle(fontFamily: 'abhaya', fontSize: 15, color: Color.fromARGB(255, 239, 68, 68),)),
  deleteTitle(TextStyle(fontFamily: 'poppins', fontSize: 22, fontWeight: FontWeight.w800)),
  deleteQuestion(TextStyle(fontFamily: 'lora', fontSize: 15, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 176, 176, 176))),
  deleteButton(TextStyle(fontFamily: 'poppins', fontSize: 15, fontWeight: FontWeight.w800));

  final TextStyle value;

  const TextStyles(this.value);
}