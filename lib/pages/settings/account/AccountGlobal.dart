import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../themes/themeProvider.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

/// text field of the login pages
class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enableBorder;

  const AuthTextField({
    super.key,
    this.controller,
    this.hintText,
    this.enableBorder = false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyles.textBox.value,
      decoration: InputDecoration(
        enabledBorder: (enableBorder) ? OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: context.colorScheme.error, width: 2),) : null,
        focusedBorder: (enableBorder) ? OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: context.colorScheme.error, width: 2),) : null,
        hintText: hintText,
        hintStyle: TextStyles.textBox.value,
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// indicate various errors that can occurs while authenticating
enum AuthError {
  passwordMismatch(0),
  emailMalformed(1),
  usernameUnavailable(2),
  firebaseError(3),
  wrongPassword(4),
  weakPassword(5),
  emailAlreadyUsed(6);

  final id;
  const AuthError(this.id);
}

/// manage google login
Future<void> signInWithGoogle() async {
  final GoogleSignInAccount googleUser;
  try {
    googleUser = await GoogleSignIn.instance.authenticate();
  } on GoogleSignInException catch(e) {
    return Future.error(AuthError.firebaseError);
  }
  final credential = GoogleAuthProvider.credential(idToken: googleUser.authentication.idToken);
  await FirebaseAuth.instance.signInWithCredential(credential);
}