import 'package:flutter/material.dart';

import 'package:daily_history/global.dart';

/// app page for theme settings
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
        showBackButton: true,
        barConfiguration: BarConfigurations.large,
        title: context.l10n.theme,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 10,),
                Text(
                  context.l10n.theme,
                  style: TextStyles.title.value,
                ),
                const Spacer(),
                SwipeButton(
                    context.l10n.light,
                    context.l10n.dark,
                    onPressed: (_) => ThemeProvider.instance.swapTheme(),
                    preset: !ThemeProvider.instance.theme.value
                ),
                const SizedBox(width: 50),
              ],
            ),
          ],
        )
    );
  } //column con expanded??
}