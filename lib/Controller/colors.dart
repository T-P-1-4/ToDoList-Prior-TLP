import 'package:flutter/material.dart';
import 'package:todo_appdev/Controller/controller.dart';

class AppColorController extends ChangeNotifier {
  final Map<String, ColorScheme> _colorSchemes = {
    // Standardfarben
    'lightBlue': ColorScheme.fromSeed(seedColor: Colors.lightBlue),
    'green': ColorScheme.fromSeed(seedColor: Colors.green),
    'deepPurple': ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    'orange': ColorScheme.fromSeed(seedColor: Colors.orange),
    'amber': ColorScheme.fromSeed(seedColor: Colors.amber),
    'red': ColorScheme.fromSeed(seedColor: Colors.red),
    'pink': ColorScheme.fromSeed(seedColor: Colors.pink),
    'purple': ColorScheme.fromSeed(seedColor: Colors.purple),
    'lime': ColorScheme.fromSeed(seedColor: Colors.lime),
    'tealAccent': ColorScheme.fromSeed(seedColor: Colors.tealAccent),
    'blue': ColorScheme.fromSeed(seedColor: Colors.blue),

    // Fest definierte Pastell-Themes
    'pastelPink': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFFD1DC),
      onPrimary: Colors.black,
      secondary: Color(0xFFFFC0CB),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFFFEEF0),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelMint': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFAAF0D1),
      onPrimary: Colors.black,
      secondary: Color(0xFF98FB98),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFF0FFF0),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelLavender': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFE6E6FA),
      onPrimary: Colors.black,
      secondary: Color(0xFFD8BFD8),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFF5F5FF),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelPeach': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFFE5B4),
      onPrimary: Colors.black,
      secondary: Color(0xFFFFDAB9),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFFFF5E6),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelSky': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFB0E0E6),
      onPrimary: Colors.black,
      secondary: Color(0xFFAFEEEE),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFE6FAFF),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelAqua': ColorScheme(
      brightness: Brightness.light,
      // primary: Color(0xFFE0FFFF),
      primary: Color(0xFFB2DFDB),
      onPrimary: Colors.black,
      // secondary: Color(0xFFB2DFDB),
      secondary: Color(0xFF80CBC4),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      // surface: Color(0xFFE6FFFA),
      surface: Color(0xFFE0F2F1),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelLilac': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFDCD0FF),
      onPrimary: Colors.black,
      secondary: Color(0xFFEBDEF0),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFF6F0FF),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    'pastelYellow': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFFFFB3),
      onPrimary: Colors.black,
      secondary: Color(0xFFFFFACD),
      onSecondary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFFFFFE0),
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
  };


  String _currentColor = 'lightBlue';

  ColorScheme get currentColorScheme => _colorSchemes[_currentColor]!;

  String get currentColorKey => _currentColor;

  ColorScheme colorSchemeByKey(String key) {
    if (_colorSchemes.containsKey(key)) {
      return _colorSchemes[key]!;
    } else if (key == 'customColor' && _customColor != null) {
      return _customColor!;
    } else {
      return _colorSchemes['lightBlue']!;
    }
  }

  void setColorScheme(String color) {
    if (_colorSchemes.containsKey(color)) {
      _currentColor = color;
      notifyListeners();
    }
  }

  List<String> get availableSchemes => _colorSchemes.keys.toList();

  ColorScheme? _customColor;

  void setCustomColorScheme(Color customBase, {bool markAsSelected = true}) {
    _customColor = ColorScheme.fromSeed(seedColor: customBase);
    _colorSchemes['customColor'] = _customColor!;
    if (markAsSelected) {
      _currentColor = 'customColor';
      Controller.writeHiveColor('customColor');
    }
    else{
      _currentColor = 'customColor';
    }
    notifyListeners();

    Controller.writeHiveCustomColor(customBase);
  }

  Color? getCustomColor() => _customColor?.primary;
}
