import 'package:flutter/material.dart';
import '../Model/priority_enum.dart';

class PrincipleController extends ChangeNotifier {
  PriorityEnum _selected = PriorityEnum.OwnPriority;

  PriorityEnum get selected => _selected;

  void setSelected(PriorityEnum p) {
    _selected = p;
    notifyListeners();
  }
}
