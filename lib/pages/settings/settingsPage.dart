import 'package:daily_history/global.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// main page for app settings
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  void Function() _pushRoute(String route, BuildContext context) {
    return () => Navigator.of(context).pushNamed(route);
  }

  void Function() openWebsite(String url) {
    return () {
      final Uri uri = Uri.parse(url);
      launchUrl(uri, mode: LaunchMode.externalApplication);
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.options,
      barConfiguration: BarConfigurations.large,

      child: Column(
        children: [
          SettingsButton(_pushRoute('/account', context), icon: const Icon(CustomIcons.profile, size: 37,), text: context.l10n.account,),
          SettingsButton(_pushRoute('/language', context), icon: const Icon(CustomIcons.language, size: 37,), text: context.l10n.language),
          SettingsButton(_pushRoute('/notifications', context), icon: const Icon(CustomIcons.notificationBell, size: 37,), text: context.l10n.notifications),
          SettingsButton(_pushRoute('/theme', context), icon: const Icon(CustomIcons.theme, size: 37,), text: context.l10n.theme),
          //TODO: insert real urls
          SettingsButton(openWebsite('https://www.google.com'), icon: const Icon(CustomIcons.review, size: 37,), text: context.l10n.reviewUs, arrow: false),
          SettingsButton(openWebsite('https://www.google.com'), icon: const Icon(CustomIcons.language, size: 37,), text: context.l10n.legalMentions, arrow: false),
        ],
      )
    );
  }
}

/// custom settings option
class SettingsButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final bool arrow;

  final Function() onPressed;

  const SettingsButton(this.onPressed, {super.key, required this.icon, required this.text, this.arrow = true});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 4,),
          Text(text, style: TextStyles.settingsTitle.value,),
          const Spacer(),
          if(arrow) const Icon(Icons.arrow_forward_ios)
        ],
      ),
    );
  }
}