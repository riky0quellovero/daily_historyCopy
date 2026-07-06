import 'package:flutter/material.dart';

import 'package:daily_history/l10n/localeProvider.dart';
import 'package:daily_history/global.dart';


/// app page for language settings
class LanguagePage extends StatelessWidget {
  LanguagePage({super.key});

  final ValueNotifier<String> _selected = ValueNotifier(LocaleProvider.instance.locale.languageCode);

  static const languageMap = {
    'Italiano (Italian)': 'it',
    'English': 'en',
    'Francois (French)': 'fr',
    '中国人 (Chinese)': 'zh',
    'Deutsch': 'de',
    'Espanol': 'es',
    'Portugues': 'pt',
  };

  @override
  Widget build(BuildContext context) {
    return AppPage(
      showBackButton: true,
      title: context.l10n.language,
      barConfiguration: BarConfigurations.large,

      child: Column(
        children: List<Widget>.generate(languageMap.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                LanguageButton(
                  selector: _selected,
                  id: languageMap.values.toSet().elementAt(index),
                ),
                const SizedBox(width: 20,),
                Text(
                  languageMap.keys.toSet().elementAt(index),
                  style: TextStyles.language.value,
                ),
              ],
            ),
          );
        })
      ),
    );
  }
}

/// button for language page
class LanguageButton extends StatelessWidget {
  final ValueNotifier<String> selector;
  final String id;

  const LanguageButton({required this.selector, required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selector.value = id;
        LocaleProvider.instance.setLocale(Locale(id));
      },
      child: ListenableBuilder(
        listenable: selector, builder: (context, _) =>
          Container(
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                  border: (selector.value == id) ? BoxBorder.all(color: Theme.of(context).colorScheme.tertiary, width: 2) : null
              ),
              child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    child: const SizedBox(height: 15, width: 15,),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (selector.value == id) ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
                    ),
                  )
              )
          ),
      ),
    );
  }
}