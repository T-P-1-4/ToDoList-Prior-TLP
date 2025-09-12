import 'package:flutter_test/flutter_test.dart';
import 'package:todo_appdev/Model/list_item.dart';
import 'package:todo_appdev/Model/item_list.dart';

void main() {
  group('ItemList', () {
    late ItemList list;
    late ListItem item;

    setUp(() {
      /// Sets up a test ItemList and test ListItem
      list = ItemList();
      item = ListItem(["Test", "Beschreibung", "1", "10", "min", "2025-01-01"]);
    });

    /// Tests if an item is being added if it's not already present
    test('Item is added if not present', () {
      final result = list.add(item);
      expect(result, isTrue);
      expect(list.contains(item), isTrue);
    });

    /// Tests if adding the exact same item to the list fails
    test('Adding same item again fails', () {
      list.add(item);
      final result = list.add(item);
      expect(result, isFalse);
    });

    /// Tests if the item is being removed correctly
    test('Item is removed correctly', () {
      list.add(item);
      final removed = list.remove(item);
      expect(removed.getTitle, item.getTitle);
      expect(list.contains(item), isFalse);
    });

    /// Tests if removing a nonexisting item from the list throws an Exception
    test('Removing non-existing item throws Exception', () {
      expect(() => list.remove(item), throwsException);
    });
  });
}
