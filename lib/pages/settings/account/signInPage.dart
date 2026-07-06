import 'package:daily_history/pages/settings/account/AccountGlobal.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:daily_history/global.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_svg/flutter_svg.dart';

/// page for app sign in
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.account,
      showBackButton: true,
      barConfiguration: BarConfigurations.large,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.signIn, style: TextStyles.barTitle.value,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    _SignInForm(),
                    const SizedBox(height: 30),

                    //or sign in with
                    Row(
                      children: [
                        Expanded(child: Divider(color: context.colorScheme.outline, thickness: 1.5,),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(context.l10n.signInAlternative, style: TextStyles.settingsSubtitle.value,),
                        ),
                        Expanded(child: Divider(color: context.colorScheme.outline, thickness: 1.5,),),
                      ],
                    ),

                    //google sign in button
                    const SizedBox(height: 30),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: GestureDetector(
                          onTap: () {
                            signInWithGoogle().then((_) {
                              if(!context.mounted) return;
                              Navigator.of(context).popUntil(
                                      (route) => route.settings.name != '/account/signUp'
                              );
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: BoxBorder.symmetric(vertical: BorderSide(color: context.colorScheme.tertiary, width: 4), horizontal: BorderSide(color: context.colorScheme.tertiary, width: 2.5))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: SvgPicture.asset('assets/images/logo_google.svg', height: 22),
                                ),

                                Text('Google', style: TextStyles.notificationTitle.value,),
                                const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    //sign up redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.noAccount, style: TextStyles.settingsSubtitle.value,),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacementNamed('/account/signUp'),
                          child: Text(' ' + context.l10n.joinUs, style: TextStyles.settingsSubtitle.value.copyWith(color: context.colorScheme.tertiary),),
                        )
                      ],
                    ),
                  ]
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// manage the sign in
class _SignInForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() { return _SignInFormState(); }
}

class _SignInFormState extends State<_SignInForm> {

  AuthError? currError;

  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// mail
        AuthTextField(
          controller: _mailController,
          hintText: context.l10n.email,
          enableBorder: currError == AuthError.emailMalformed,
        ),
        const SizedBox(height: 15),
        if(currError == AuthError.emailMalformed)
          Text(context.l10n.emailError, style: TextStyles.errorMsg.value,),
        const SizedBox(height: 15),

        /// password
        AuthTextField(
          controller: _passwordController,
          hintText: context.l10n.password,
          enableBorder: currError == AuthError.wrongPassword,
        ),
        const SizedBox(height: 10,),
        if(currError == AuthError.wrongPassword)
          Text(context.l10n.passwordSignError, style: TextStyles.errorMsg.value,),
        if(currError == AuthError.firebaseError)
          Text(context.l10n.firebaseError, style: TextStyles.errorMsg.value,),
        const SizedBox(height: 10,),

        /// forgot password
        GestureDetector(
          onTap: () {
            //TODO: feedback?
            sendPasswordResetEmail(_mailController.text);
          },
          child: Text(
              context.l10n.forgetPass,
              style: TextStyles.settingsSubtitle.value.copyWith(color: context.colorScheme.onPrimary, decoration: TextDecoration.underline)
          ),
        ),
        const SizedBox(height: 20),

        /// sign in button
        AppContainer(
          width: double.infinity,
            color: Theme.of(context).colorScheme.tertiary,
          child: TextButton(
            onPressed: () => _manageAuth(_mailController.text, _passwordController.text, context)
            .then((_) {
              FirebaseAnalytics.instance.setUserId(id: FirebaseAuth.instance.currentUser!.uid);
              Navigator.of(context).pop();
            } )
            .catchError((error) {
              currError = error;
              setState(() {});
            }),
            child: Text(context.l10n.signIn, style: TextStyles.title.value.copyWith(color: Colors.white)),
          ),
        )
      ],
    );
  }
}

Future<void> _manageAuth(String mail, String password, BuildContext context) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: password);
    Navigator.of(context).pushReplacementNamed('/account');
  } on FirebaseAuthException catch (e) {
    AuthError error;
    print(e.code);
    switch (e.code) {
      case 'invalid-credential':
        error = AuthError.wrongPassword;
      case 'user-not-found':
        error = AuthError.emailMalformed;
        break;
      case 'wrong-password':
        error = AuthError.wrongPassword;
        break;
      case 'invalid-email':
        error = AuthError.emailMalformed;
        break;
      case 'user-disabled':
        error = AuthError.firebaseError;
        break;
      default:
        error = AuthError.firebaseError;
    }
    return Future.error(error);
  }
}

//TODO: better
void sendPasswordResetEmail(String mail) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
    print("Email di reset inviata a $mail");
  } catch (e) {
    print("Errore durante l'invio dell'email di reset: $e");
  }
}