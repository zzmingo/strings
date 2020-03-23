import 'package:strings/i10n/messages_all.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StringsLocalizations {

  static Future<StringsLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new StringsLocalizations();
    });
  }

  static StringsLocalizations of(BuildContext context) {
    return Localizations.of<StringsLocalizations>(context, StringsLocalizations);
  }

  String get appName => Intl.message("Strings", name: 'appName');
  String get tuner => Intl.message("Tuner", name: 'tuner');
  String get auto => Intl.message("Auto", name: 'auto');
  String get add => Intl.message("Add", name: 'add');
  String get delete => Intl.message("Delete", name: 'delete');
  String get cancel => Intl.message("Cancel", name: 'cancel');
  String get confirm => Intl.message("Confirm", name: 'confirm');
  String get noticeTitle => Intl.message("Notice", name: "noticeTitle");
  String get tunerSettings => Intl.message("Tuner Settings", name: 'tunerSettings');
  String get customTunings => Intl.message("Custom tunings", name: 'customTunings');
  String get customTuningsWithTips => Intl.message("Custom tunings (long press to delete)", name: 'customTuningsWithTips');
  String get commonTunings => Intl.message("Common tunings", name: 'commonTunings');
  String get confirmDeleteTuning => Intl.message("Delete this tuning?", name: "confirmDeleteTuning");
  String get tuningNameDialogTitle => Intl.message("Tuning name", name: "tuningNameDialogTitle");
  String get noCustomTunings => Intl.message("No custom tuning", name: "noCustomTunings");
  String get tuningName => Intl.message("Tuning name", name: "tuningName");
  String get strings => Intl.message("Strings", name: "strings");
  String get nameForTuning => Intl.message("Name for this tuning", name: "nameForTuning");
  String get addCustomTuning => Intl.message("Add custom tuning", name: "addCustomTuning");
  String get ok => Intl.message("OK", name: "ok");
  String get errorTipsTuningName => Intl.message("Name cannot be empty.", name: "errorTipsTuningName");
  String get errorTipsStringsEmpty => Intl.message("Please select strings.", name: "errorTipsStringsEmpty");
  String get autoImageName => Intl.message("auto-en", name: "autoImageName");
  String get autoImageHName => Intl.message("auto-h-en", name: "autoImageHName");


}

class StringsLocalizationsDelegate extends LocalizationsDelegate<StringsLocalizations> {

  const StringsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<StringsLocalizations> load(Locale locale) {
    return StringsLocalizations.load(locale);
  }

  @override
  bool shouldReload(StringsLocalizationsDelegate old) => false;
}