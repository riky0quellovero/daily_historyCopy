import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// provide notification settings interface
/// allow to manage notifications time by [setNotificationsTime]
/// and if they are enabled with [setNotificationEnable]
/// save preferences in local
class NotificationsProvider {
  // Singleton setup
  static final NotificationsProvider instance = NotificationsProvider._internal();
  NotificationsProvider._internal();

  static const _dataKey = 'selected_notification';

  //values
  bool _notificationsEnabled = true;
  TimeOfDay _notificationsTime = const TimeOfDay(hour: 9, minute: 0);

  //getters
  bool get areEnabled => _notificationsEnabled;
  TimeOfDay get notificationsTime => _notificationsTime;

  /// loads the saved settings
  //TODO: test the data loading system
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_dataKey);

    if (code != null && code.isNotEmpty) {
      _notificationsEnabled = bool.parse(code.split(' ')[0]);
      _notificationsTime = TimeOfDay(hour: int.parse(code.split(' ')[1]), minute: 0);
    }
  }

  /// set a new notification time
  Future<void> setNotificationsTime(TimeOfDay notificationsTime) async {
    if(_notificationsTime == notificationsTime) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, '$_notificationsEnabled ${_notificationsTime.hour}');
  }

  /// set if the notifications are enabled
  Future<void> setNotificationEnable(bool enabled) async {
    if(enabled == _notificationsEnabled) return;

    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, '$_notificationsEnabled ${_notificationsTime.hour}');
  }
}
