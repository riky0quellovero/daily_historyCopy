import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:daily_history/cookieProvider.dart';
import 'package:daily_history/pages/saved/savedProvider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: check

class AnalyticsManager {
  static final AnalyticsManager instance = AnalyticsManager._internal();
  static const _prefKey = 'firstSave';
  static const _installKey = 'installDate';
  static late bool firstSaved;
  static late Timestamp installtionDate;

  AnalyticsManager._internal() {
    CookieProvider.instance.addListener(() async {
      if(CookieProvider.instance.pref == true) await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    });
  }

  Future<void> init() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    final prefs = await SharedPreferences.getInstance();
    firstSaved = prefs.getBool(_prefKey) ?? false;
    installtionDate = Timestamp.fromMillisecondsSinceEpoch(prefs.getInt(_installKey) ?? Timestamp.now().millisecondsSinceEpoch);
  }

  Future<void> updateSavedMetrics(bool added) async {
    if(CookieProvider.instance.pref == false) return;

    if(added) {
      await FirebaseAnalytics.instance.logEvent(
        name: "save_character",
      );

      if(!firstSaved && SavedProvider.instance.savedDates.length == 1) {
        await FirebaseAnalytics.instance.logEvent(
          name: "first_save_character",
          parameters: {
            "days_since_install": Timestamp.now().seconds / 86400 - installtionDate.seconds / 86400,
          },
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKey, true);
      }
    }
    else {
      await FirebaseAnalytics.instance.logEvent(
        name: "delete_character",
      );

    }

    await FirebaseAnalytics.instance.setUserProperty(
      name: "saved_characters",
      value: SavedProvider.instance.savedDates.length.toString(),
    );
  }

  void LectureMetricReader(ScrollController controller, Timestamp date) {
    int max = 0;
    Timer? debounceTimer;

    controller.addListener(() {
      if (!controller.hasClients) return;

      final maxScroll = controller.position.maxScrollExtent;
      final currentScroll = controller.position.pixels;

      if (maxScroll <= 0) return;

      final percentage = (currentScroll / maxScroll) * 100;
      int cap = (percentage ~/ 10) * 10;
      if (cap > 100) cap = 100;

      if (cap <= max) return;
      max = cap;

      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(seconds: 5), () {
        FirebaseAnalytics.instance.logEvent(
          name: 'lecture_progress',
          parameters: {
            'article_date': date.millisecondsSinceEpoch,
            'percentage': cap,
          },
        );
      });
    });
  }

  Future<void> shareTracing({
    required String contenutoId,
    required String tipoContenuto, // es. "articolo", "video", "ricetta"
    required String metodoCondivisione, // es. "whatsapp", "telegram", "generic_clip"
  }) async {

    await FirebaseAnalytics.instance.logShare(
      contentType: tipoContenuto,
      itemId: contenutoId,
      method: metodoCondivisione,
    );

  }
}