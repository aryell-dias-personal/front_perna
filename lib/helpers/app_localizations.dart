import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perna/constants/constants.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  AppLocalizations.of(BuildContext context) {
    locale = Localizations.localeOf(context);
  }

  late Locale locale;

  Map<String, String>? _localizedStrings;
  Map<String, String>? _defaultLocalizedStrings;

  Future<bool> load() async {
    final String jsonString =
        await rootBundle.loadString('lang/${locale.languageCode}.json');
    final String defaultJsonString =
        await rootBundle.loadString('lang/$defaultLanguageCode.json');
    final Map<String, dynamic> jsonMap =
        json.decode(jsonString) as Map<String, dynamic>;
    final Map<String, dynamic> defaultjsonMap =
        json.decode(defaultJsonString) as Map<String, dynamic>;

    _localizedStrings = jsonMap.map((String key, dynamic value) {
      return MapEntry<String, String>(key, value.toString());
    });
    _defaultLocalizedStrings = defaultjsonMap.map((String key, dynamic value) {
      return MapEntry<String, String>(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return (_localizedStrings?[key] ?? _defaultLocalizedStrings?[key]) ?? '';
  }

  String translateFormat(String key, List<dynamic> formatters) {
    return translate(key).replaceAllMapped('<?>', (Match match) {
      final dynamic replacement = formatters.first;
      formatters.remove(replacement);
      return '$replacement';
    });
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return <String>['en', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
