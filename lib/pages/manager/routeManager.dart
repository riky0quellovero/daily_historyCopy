import 'package:flutter/material.dart';

//page imports
import 'package:daily_history/pages/calendar/calendarPage.dart';
import 'package:daily_history/pages/figure/figurePage.dart';
import 'package:daily_history/pages/saved/savedPage.dart';
import 'package:daily_history/pages/settings/settingsPage.dart';

import '../settings/settingsRouteNavigator.dart';


/// manage the route root system for the main pages
Route<Object?> routeGenerator(RouteSettings settings) {
  switch(settings.name) {
    case '/daily':
      return MaterialPageRoute(builder: (_) => FigurePage(date: settings.arguments as DateTime?));
    case '/saved':
      return MaterialPageRoute(builder: (_) => SavedPage());
    case '/settings':
      return settingsRouteGenerator();
    case '/calendar':
      return MaterialPageRoute(builder: (_) => CalendarPage());
  }
  return MaterialPageRoute(builder: (_) => const Text('whoops'));
  //TODO: better error management
}