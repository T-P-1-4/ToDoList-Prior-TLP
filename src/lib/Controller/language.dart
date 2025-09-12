import 'dart:convert';
import 'package:flutter/services.dart';

/**
 * class contains the String contend which is used in the App
 * It uses a Map for selecting the language and a Map for containing all Phrases we have to use.
 * Use Language.getText() notation
 * */
class Language {
  Language ();

  static String _currentLanguage = 'de';
  static Map<String, Map<String, String>> _languageMap = {};

  static String getCurrentLanguage() => _currentLanguage;
  static List<String> getAvailableLanguages() => _languageMap.keys.toList();

  static void setLanguage(String languageCode) {
    if (_languageMap.containsKey(languageCode)) {
      _currentLanguage = languageCode;
    }
  }

  static Future<void> loadLanguageFile() async {
    final String jsonString = await rootBundle.loadString('lib/config/lang.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    _languageMap = jsonData.map((lang, value) {
      final Map<String, String> stringMap = Map<String, String>.from(value as Map);
      return MapEntry(lang, stringMap);
    });
  }

  static getText(String key) {
    return _languageMap[_currentLanguage]?[key] ?? '[$key]';
  }
}
