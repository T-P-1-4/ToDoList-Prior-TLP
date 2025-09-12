import 'package:flutter_test/flutter_test.dart';
import 'package:todo_appdev/Controller/navigation_controller.dart';
import 'package:todo_appdev/Model/navigation_item.dart';

void main() {
  group('NavigationController', () {

    /// Tests if the initial selected NavigationItem is the mainPage Item
    test('initial selected item is mainPage', () {
      final controller = NavigationController();
      expect(controller.selectedItem, NavigationItem.mainPage);
    });

    /// Tests if the selectItem method of the NavController updates the selected item
    test('selectItem updates the selected item', () {
      final controller = NavigationController();
      controller.selectItem(NavigationItem.settings);
      expect(controller.selectedItem, NavigationItem.settings);
    });
  });
}
