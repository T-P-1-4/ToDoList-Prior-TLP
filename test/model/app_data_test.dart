import 'package:flutter_test/flutter_test.dart';
import 'package:todo_appdev/Model/app_data.dart';
import 'package:todo_appdev/Model/list_item.dart';

void main() {
  group('AppData', () {
    late AppData data;
    late ListItem item;
    const fixedTimestamp = "2025-05-08T17:58:00.000Z";

    /// Beispiel-Input mit optionalem Timestamp (an letzter Stelle)
    List<String> sampleItemData({String? timestamp}) {
      return [
        "Essen kochen",
        "Reis machen",
        "2",
        "1",
        "h",
        "2025-06-01",
        if (timestamp != null) timestamp
      ];
    }


    setUp(() {
      data = AppData();
      item = ListItem(sampleItemData(timestamp: fixedTimestamp));
      data.getUncheckedList.add(item);
    });

    /// Tests if item is initially in unchecked List, and not in checked List
    test('Item is initially in unchecked list', () {
      expect(data.getUncheckedList.contains(item), isTrue);
      expect(data.getCheckedList.contains(item), isFalse);
    });

    /// Tests if the item is correctly being moved to the checkedList when the
    /// setItemChecked method in called form the AppData class
    test('Item is moved to checked list', () {
      data.setItemChecked(item);
      expect(data.getCheckedList.contains(item), isTrue);
      expect(data.getUncheckedList.contains(item), isFalse);
    });

    /// Tests if item is being moved back to the unchecked List correctly
    test('Item is moved back to unchecked list', () {
      data.setItemChecked(item);
      data.setItemUnchecked(item);
      expect(data.getUncheckedList.contains(item), isTrue);
      expect(data.getCheckedList.contains(item), isFalse);
    });

    /// Tests if the item is correctly being deleted form both lists
    /// since deleteItem method in AppData already should delete form both lists
    /// and there are no two different methods for deleting form different lists
    test('Item is deleted from both lists', () {
      data.deleteItem(item);
      expect(data.getCheckedList.contains(item), isFalse);
      expect(data.getUncheckedList.contains(item), isFalse);
    });
  });
}
