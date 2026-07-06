import 'package:daily_history/pages/settings/notifications/notificationsPage.dart';
import 'package:flutter/material.dart';

import 'package:daily_history/pages/settings/language/languagePage.dart';
import 'package:daily_history/pages/settings/theme/themePage.dart';
import 'package:daily_history/pages/settings/settingsPage.dart';

import 'account/accountRouteManager.dart';

Route<Object?> settingsRouteGenerator() {
  return MaterialPageRoute(
    builder: (_) => Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name!.split('/')[1]) {
          case '':
            return MaterialPageRoute(builder: (_) => const SettingsPage());
          case 'account':
            return accountRouteGenerator(settings);
          case 'language':
            return MaterialPageRoute(builder: (_) => LanguagePage());
          case 'notifications':
            return MaterialPageRoute(builder: (_) => NotificationsPage());
          case 'theme':
            return MaterialPageRoute(builder: (_) => ThemePage());
          default:
            //TODO: implement better error handling
            return MaterialPageRoute(builder: (_) => const Text('whoopsy'));
        }
      },
    ),
  );
}