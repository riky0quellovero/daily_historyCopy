import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:daily_history/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:daily_history/pages/settings/account/AccountGlobal.dart';

/// app page for sign up
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      showBackButton: true,
      barConfiguration: BarConfigurations.large,
      title: context.l10n.account,

      child: Column(
        children: [
          //sign up text
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 25),
              child: Text(context.l10n.signUp, style: TextStyles.barTitle.value,),
            )
          ),

          _SignUpForm(),

          //or sign in with
          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 30,),
          FractionallySizedBox(
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
                    border: BoxBorder.symmetric(
                        vertical: BorderSide(color: context.colorScheme.tertiary, width: 4),
                        horizontal: BorderSide(color: context.colorScheme.tertiary, width: 2.5)
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: SvgPicture.asset('assets/images/logo_google.svg', height: 22),
                    ),

                    Text('Google', style: TextStyles.notificationTitle.value,),
                    const SizedBox(), //for adding spaces via space around
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          //sign in redirect
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.signUpQuestion, style: TextStyles.settingsSubtitle.value,),
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacementNamed('/account/signIn'),
                child: Text(
                  ' ' + context.l10n.signIn,
                  style: TextStyles.settingsSubtitle.value.copyWith(color: context.colorScheme.tertiary)
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

/// sign up filed section
class _SignUpForm extends StatefulWidget {
  const _SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {

  //form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  AuthError? currError;

  @override
  void dispose() {
    _usernameController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //username
        AuthTextField(
          controller: _usernameController,
          hintText: context.l10n.username,
          enableBorder: currError == AuthError.usernameUnavailable,
        ),
        const SizedBox(height: 15,),
        if(currError == AuthError.usernameUnavailable)
          Text(context.l10n.usernameError, style: TextStyles.errorMsg.value,),
        const SizedBox(height: 15,),

        //mail
        AuthTextField(
          controller: _mailController,
          hintText: context.l10n.email,
          enableBorder: currError == AuthError.emailMalformed || currError == AuthError.emailAlreadyUsed,
        ),
        const SizedBox(height: 15,),
        if(currError == AuthError.emailMalformed)
          Text(context.l10n.emailError, style: TextStyles.errorMsg.value,),
        if(currError == AuthError.emailAlreadyUsed)
          Text(context.l10n.emailAlreadyUsedError, style: TextStyles.errorMsg.value,),
        const SizedBox(height: 15,),

        //password
        AuthTextField(
          controller: _passwordController,
          hintText: context.l10n.password,
          enableBorder: currError == AuthError.passwordMismatch,
        ),
        const SizedBox(height: 30,),

        //confirm password
        AuthTextField(
          controller: _confirmController,
          hintText: context.l10n.confirmPassword,
          enableBorder: currError == AuthError.passwordMismatch || currError == AuthError.weakPassword,
        ),
        const SizedBox(height: 15,),
        if(currError == AuthError.passwordMismatch)
          Text(context.l10n.passwordError, style: TextStyles.errorMsg.value,),
        if(currError == AuthError.weakPassword)
          Text(context.l10n.weakPassword, style: TextStyles.errorMsg.value,),

        //firebase possible errors
        if(currError == AuthError.firebaseError)
          Text(context.l10n.firebaseError, style: TextStyles.errorMsg.value,),
        const SizedBox(height: 15,),

        //sign up button
        AppContainer(
          color: Theme.of(context).colorScheme.tertiary,
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              if(_passwordController.text != _confirmController.text) {
                currError = AuthError.passwordMismatch;
                setState(() {});
                return;
              }

              if(_passwordController.text.length < 6) {
                currError = AuthError.weakPassword;
                setState(() {});
                return;
              }

              if(!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$").hasMatch(_mailController.text)) {
                currError = AuthError.emailMalformed;
                setState(() {});
                return;
              }

              //TODO: implement username database check and possible cloud function errors
              if(false) {
                currError = AuthError.usernameUnavailable;
                setState(() {});
                return;
              }

              /// check indietro mentre logga
              _emailAuth(_mailController.text, _passwordController.text, context)
                  .then((_) {
                    FirebaseAnalytics.instance.setUserId(id: FirebaseAuth.instance.currentUser!.uid);
                // Controllo che il widget sia ancora montato
                if (!mounted) return;

                Navigator.of(context).pop();
              }).catchError((error) {
                // Controllo mounted prima di aggiornare UI
                if (!mounted) return;

                currError = error;
                setState(() {});
              });
            },
            child: Text(context.l10n.signUp, style: TextStyles.title.value.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

Future<void> _emailAuth(String mail, String password, BuildContext context) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: password);
    Navigator.of(context).pushReplacementNamed('/account');
  } on FirebaseAuthException catch (e) {
    if(e.code == 'weak-password')
      return Future.error(AuthError.weakPassword);
    if(e.code == 'email-already-in-use')
      return Future.error(AuthError.emailAlreadyUsed);
    return Future.error(AuthError.firebaseError);
  }
}


//TODO: use mail confirm to create user