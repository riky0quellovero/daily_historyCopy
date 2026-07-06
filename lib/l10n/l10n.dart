import 'package:flutter/material.dart';
import '../generated/app_localization.dart';

/// return current l10n system
extension AppLocalizationsExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}