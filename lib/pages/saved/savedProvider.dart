import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../analyticsManager.dart';
import '../../global.dart';

//TODO: sync multiple devices

class SavedProvider extends ChangeNotifier {
  static final SavedProvider instance = SavedProvider._internal();
  SavedProvider._internal() {
    //nullify list values when the auth state is changed
    _auth.authStateChanges().listen(_handleAuthChange);
  }

  List<Timestamp> _saved = [];

  Future<void> init() async {
    final user = _auth.currentUser;
    if (user == null) return;

    var doc;

    try {
      doc = await _db
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.cache));
    } catch(_) {
      doc = await _db
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
    }

    final data = doc.data();

    if (data != null && data['saved'] is List) {
      _saved = List<Timestamp>.from(data['saved']);
    }
    print('read: ${savedDates![0].millisecondsSinceEpoch}');
    notifyListeners();
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = firestore;

  List<Timestamp> get savedDates => _auth.currentUser != null ? List.unmodifiable(_saved) : [];

  void _handleAuthChange(User? user) {
    //_saved.clear();

    if (user == null) {
      notifyListeners();
      return;
    }

    //TODO: handle user logging after init called
    init();
  }

  final Map<String, Timer> _debounceTimers = {};

  Future<void> addSaved(String date) async {
    final user = _auth.currentUser;
    final timestamp = Timestamp.fromDate(DateTime.parse(date));
    if (user == null || _saved.contains(timestamp)) return;

    _saved.add(timestamp);
    notifyListeners();

    _debounceTimers[date]?.cancel();
    _debounceTimers[date] = Timer(const Duration(seconds: 2), () async {
      await _db.collection('users').doc(user.uid).update({
        "saved": FieldValue.arrayUnion([timestamp])
      });
      AnalyticsManager.instance.updateSavedMetrics(true);
      _debounceTimers.remove(date);
    });
  }

  Future<void> removeSaved(String date) async {
    final user = _auth.currentUser;
    final timestamp = Timestamp.fromDate(DateTime.parse(date));
    if (user == null || !_saved.contains(timestamp)) return;

    _saved.remove(timestamp);
    notifyListeners();

    _debounceTimers[date]?.cancel();
    _debounceTimers[date] = Timer(const Duration(seconds: 2), () async {
      await _db.collection('users').doc(user.uid).update({
        "saved": FieldValue.arrayRemove([timestamp])
      });
      AnalyticsManager.instance.updateSavedMetrics(false);
      _debounceTimers.remove(date);
    });
  }

// Da aggiungere nel dispose() della classe
  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }
}

//TODO; upgrade debounce with workmanager plugin for reliable kill hooks
