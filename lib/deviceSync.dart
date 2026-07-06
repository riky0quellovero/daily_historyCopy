import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

//TODO: check
//TODO: campi specializzati ios e settaggio su xCOde
//TODO: collapse key


///callback for background and killed
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _printMessageData(message);
}

void _printMessageData(RemoteMessage message) {
  final data = message.data;

  Timestamp like = data['like'];

  final saved = data['saved'] != null ? (jsonDecode(data['saved']!) as List<Timestamp>) : [];
  String username = data['username'];

  //TODO: change likes and saved
  print("timestamp: $like");
  print("timestamps: $saved");
}

//TODO: really change notifier cause saved and likes can already have changenotifier
class DeviceSyncManager extends ChangeNotifier {

  static final instance = DeviceSyncManager._internal();
  DeviceSyncManager._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  User? _currentUser;


  Future<void> init() async {

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );


    FirebaseMessaging.onMessage.listen((message) {
      _printMessageData(message);
      notifyListeners();
    });


    FirebaseAuth.instance.authStateChanges()
        .listen(_authChanged);
  }


  Future<void> _authChanged(User? user) async {

    if (_currentUser != null) {
      await _messaging.unsubscribeFromTopic(
        "user_${_currentUser!.uid}",
      );
    }


    _currentUser = user;


    if (user != null) {
      await _messaging.subscribeToTopic(
        "user_${user.uid}",
      );
    }
  }
}