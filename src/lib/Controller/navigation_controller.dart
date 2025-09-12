import 'package:flutter/material.dart';
import 'package:todo_appdev/Model/navigation_item.dart';

class NavigationController extends ChangeNotifier {
  NavigationItem _selectedItem = NavigationItem.mainPage;

  NavigationItem get selectedItem => _selectedItem;

  void selectItem(NavigationItem item) {
    _selectedItem = item;
    notifyListeners();
  }
}