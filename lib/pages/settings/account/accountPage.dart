import 'package:daily_history/global.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      showBackButton: true,
      title: 'Account',
      barConfiguration: BarConfigurations.large,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          Text(context.l10n.email, style: TextStyles.title.value,),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              FirebaseAuth.instance.currentUser!.email!,
              style: TextStyles.title.value.copyWith(color: context.colorScheme.outline),
            ),
          ),
          Divider(color: context.colorScheme.secondary,),
          const SizedBox(height: 25,),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              FirebaseAnalytics.instance.setUserId(id: null);
              if(context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(CustomIcons.logout, size: 35,),
                const SizedBox(width: 15,),
                Text(context.l10n.out, style: TextStyles.title.value,),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  showCustomBanner(context);
                },
                child: Icon(CustomIcons.profileDelete, color: context.colorScheme.tertiary, size: 35,),
              ),
              const SizedBox(width: 15,),
              Text(
                context.l10n.deleteAccount,
                  style: TextStyles.title.value.copyWith(color: context.colorScheme.tertiary, decoration: TextDecoration.underline, decorationColor: context.colorScheme.tertiary)
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//TODO: correct light design
void showCustomBanner(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.2),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: AppContainer(
            width: double.infinity,
            color: context.colorScheme.secondary,
            height: MediaQuery.of(context).size.height * 0.43,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(context.l10n.deleteAccount, style: TextStyles.deleteTitle.value),
                Text(context.l10n.deleteQ, style: TextStyles.deleteQuestion.value),
                GestureDetector(
                  onTap: () {
                    //TODO: manage exceptions via future on error
                    FirebaseAuth.instance.currentUser!.delete();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: AppContainer(
                    color: context.colorScheme.tertiary,
                    borderRadius: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      child: Text(context.l10n.delete, style: TextStyles.deleteButton.value.copyWith(color: context.colorScheme.surface),),
                    )
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        shape: BoxShape.circle
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.close, size: 25)
                    )
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      );
    },
  );
}