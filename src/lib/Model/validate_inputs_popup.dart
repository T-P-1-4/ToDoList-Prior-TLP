import 'package:flutter/cupertino.dart';

class InputValidation extends ChangeNotifier{

  // Title
  bool title(String newTitle) {
    if (newTitle.isNotEmpty) {
      notifyListeners();
      return true;     // Input is valid
    } else {
      return false;
    }
  }

  // Effort Value
  int effortValue(String newValue) {
    if (RegExp(r'^[0-9]+$').hasMatch(
        newValue)) { // Prüft, ob die Eingabe nur Zahlen enthält
      int parsedValue = int.parse(newValue);
      if (parsedValue >= 0) {
        notifyListeners();
        return 0;   // Input is valid
      } else {
        return 1; // Error: Zahl muss größer/gleich als 0 sein
      }
    } else {
      return 2; // Error: Bitte nur Zahlen eingeben
    }
  }

  // Effort Unit
  bool effortUnit(String newUnit) {
    if (['min', 'h', 'd'].contains(newUnit)) {
      notifyListeners();
      return true;     // Input is valid
    }
    else {
      return false;
    }
  }

  // Due Date
  bool expirationDate(DateTime newDate) {
    DateTime today = DateTime.now();
    DateTime todayYMD = DateTime(today.year, today.month, today.day);
    DateTime newDateYMD = DateTime(newDate.year, newDate.month, newDate.day);
    if (!newDateYMD.isBefore(todayYMD)) {
      return true;     // Input is valid
    } else {
      notifyListeners();
      return false;
    }
  }
}
