import 'package:flutter_test/flutter_test.dart';
import 'package:todo_appdev/Model/list_item.dart';

void main() {
  group('ListItem', () {
    /// Create a sample for the ListItem initialization
    final sample = ["Hund raus bringen", "Gassi gehen", "3", "30", "min", "2025-05-06"];
    final item = ListItem(sample);

    /// Tests if Constructor processes
    test('Constructor parses duration and date correctly', () {
      // Duration time in Hours of 30 mins => 0.5 in Hours
      expect(item.getDurationTimeInHours, 0.5);
      expect(item.getExpirationDate, DateTime.parse("2025-05-06"));
    });

    /// Tests if the initial state of the isChecked attribute of the list_item is false
    test('Initial checked state is false', () {
      expect(item.isChecked, isFalse);
    });

    /// Tests if the setChecked method sets the isChecked attribute of the list_item to true
    test('setChecked sets checked to true', () {
      item.setChecked();
      expect(item.isChecked, isTrue);
    });

    /// Same as the method above just the other way around
    test('setUnchecked sets checked to false', () {
      item.setUnchecked();
      expect(item.isChecked, isFalse);
    });

    /// Tests the toString method and picks tow random values to check if they exist
    test('toString contains all fields', () {
      final str = item.toString();
      expect(str, contains('Hund raus bringen'));
      expect(str, contains('Checked: false'));
    });
  });
}
