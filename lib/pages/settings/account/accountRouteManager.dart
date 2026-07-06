import 'package:flutter/material.dart';

//firebase imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

//pages imports
import 'signUpPage.dart';
import 'signInPage.dart';
import 'accountPage.dart';

/// manage the account route system
Route<Object?> accountRouteGenerator(RouteSettings settings) {
  return MaterialPageRoute(
      builder: (_) {
        switch (settings.name) {
          case '/account':
            return FirebaseAuth.instance.currentUser == null
                ? const SignUpPage()
                : AccountPage();
          case '/account/signIn':
            return SignInPage();
          case '/account/signUp':
            return SignUpPage();
          default:
            return const Text('whopsy');
        }
      },
      settings: FirebaseAuth.instance.currentUser != null ? settings : const RouteSettings(name: '/account/signUp')
  );
}