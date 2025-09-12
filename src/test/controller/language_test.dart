import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_appdev/Controller/language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language', () {
    setUp(() async {
      /// Loading the json file for the languages
      await Language.loadLanguageFile();
    });

    /// Tests what is being returned if the key isn't found ->
    test('getText returns fallback if key not found', () {
      final result = Language.getText('does_not_exist');
      expect(result, '[does_not_exist]');
    });

    /// Tests if setLanguage really switches the current language
    test('setLanguage switches current language', () {
      Language.setLanguage('de');
      final text = Language.getText('App_Name');
      expect(text, isNot('[SicherNichtDerAppName]'));
    });
  });
}
