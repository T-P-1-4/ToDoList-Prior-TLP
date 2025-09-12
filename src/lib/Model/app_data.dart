import 'package:flutter/cupertino.dart';
import 'list_item.dart';
import 'item_list.dart';


class AppData extends ChangeNotifier{
  ItemList checked = ItemList();
  ItemList unchecked = ItemList();

  ItemList get getCheckedList => checked;
  ItemList get getUncheckedList => unchecked;

  void setList(ItemList c, ItemList uc) {
    checked = c;
    unchecked = uc;
    notifyListeners();
  }

  void addNewItem(ListItem i) {
    unchecked.add(i);
    notifyListeners();
  }

  void setItemChecked(ListItem i){
    unchecked.remove(i);
    i.setChecked();
    checked.add(i);
    notifyListeners();
  }

  void setItemUnchecked(ListItem i){
    checked.remove(i);
    i.setUnchecked();
    unchecked.add(i);
    notifyListeners();
  }

  void deleteItem(ListItem i){
    if (checked.contains(i)) {
      checked.remove(i);
      notifyListeners();
    }
    if (unchecked.contains(i)){
      unchecked.remove(i);
      notifyListeners();
    }
  }

}