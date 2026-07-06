//providers
import 'dart:ui';

import 'package:daily_history/analyticsManager.dart';
import 'package:daily_history/cookieProvider.dart';
import 'package:daily_history/notifications/notificationsProvider.dart';
import 'package:daily_history/pages/saved/savedProvider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

//l10n imports
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localization.dart';
import 'package:daily_history/l10n/localeProvider.dart';

//route imports
import 'package:daily_history/pages/manager/routeManager.dart';
import 'package:daily_history/pages/manager/navigatorBar.dart';

import 'global.dart';

// Create a global key for the navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  debugPaintSizeEnabled = false; // enable widget bounds
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //for some reason need to specify default (maybe corrupted cache)
  firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default'
  );

  //cache settings
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
  );

  //TODO: change for release
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  //guarantee user already loaded
  await FirebaseAuth.instance.authStateChanges().first;
  GoogleSignInPlatform.instance.init(const InitParameters());

  //load preferences providers
  await CookieProvider.instance.loadPref();
  await LocaleProvider.instance.loadLocale();
  await ThemeProvider.instance.loadTheme();
  await NotificationsProvider.instance.loadData();

  await SavedProvider.instance.init();
  await AnalyticsManager.instance.init();

  //TODO: finish implementing crashlytics
  // 2. Cattura tutti gli errori non gestiti del framework Flutter
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // 3. Cattura gli errori asincroni che avvengono fuori dal contesto Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };


  runApp(const MyApp());
}

//TODO: make it stateless?
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    //app refresh system for theme & locale changes
    return ListenableBuilder(
      listenable: Listenable.merge(
        [
          LocaleProvider.instance,
          ThemeProvider.instance
        ]
      ),
      builder: (context, child) => MaterialApp(
        //debug settings
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: true,

        //localization
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('it'),
          Locale('en'),
        ],
        locale: LocaleProvider.instance.locale,

        //allow analytics to detect navigator operations
        //TODO: finish implementing performance monitoring
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          FirebasePerformanceNavigatorObserver(),
        ],

        //themes
        theme: ThemeProvider.instance.themeData,

        //route management
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Expanded(
                child: Navigator(
                    key: navigatorKey,
                    initialRoute: '/daily',
                    onGenerateRoute: routeGenerator
                ),
              ),
              NavigatorBar(navKey: navigatorKey),
            ],
          ),
        ),

        title: 'Daily History',
      ),
    );
  }
}