import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';

const _prefKey = 'selected_pref';

///manage the state of the cookie choice of the user
class CookieProvider extends ChangeNotifier {
  //singleton setup
  static final CookieProvider instance = CookieProvider._internal();
  CookieProvider._internal();

  ///load pref from device. notify listeners for triggering analytics
  Future<void> loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    _pref = prefs.getBool(_prefKey);

    notifyListeners();
  }

  ///set new pref value. notify for analytics
  Future<void> setPref(bool val) async {
    _pref = val;

    //save change in locale
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, val);

    notifyListeners();
  }

  ///null if the user haven't choose yet
  bool? _pref = null;
  bool? get pref => _pref;
}

//TODO: review design, change reject all with more options
void showCustomBanner(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.2),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: AppContainer(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            color: context.colorScheme.secondary,
            height: MediaQuery.of(context).size.height * 0.47,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.cookieTitle, style: TextStyles.deleteTitle.value),
                Text(context.l10n.cookieText, style: TextStyles.deleteQuestion.value.copyWith(fontSize: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Reject All
                    GestureDetector(
                      onTap: () {
                        CookieProvider.instance.setPref(false);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // sfondo scuro
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Reject all",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Accept All
                    GestureDetector(
                      onTap: () {
                        CookieProvider.instance.setPref(true);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.colorScheme.tertiary, // rosso simile a quello dell’immagine
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Accept all",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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