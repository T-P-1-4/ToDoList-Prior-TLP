import 'package:flutter/cupertino.dart';
import '../Model/list_item.dart';
import '../Model/validate_inputs_popup.dart';
import 'package:flutter/material.dart';
import '../Model/item_list.dart';
import 'controller.dart';

/*
the user inputs for one list_item are checked if they are valid
 */
// - if title is not entered - button "next" is not enabled
// - if effort_value and effort_unit are not valid, button "send" is not enabled

class ListItemController extends ChangeNotifier{
  InputValidation validate = InputValidation();
  final ItemList itemList;

  // ItemList-Instanz übergeben
  ListItemController(this.itemList);
  
  // Getter
  InputValidation get val => validate;


  String? validateTitle(String newTitle) {
    if (validate.title(newTitle)) {
      return null;
    } else {
      return Controller.getTextLabel('error_message_Title');
    }
  }

  String? validateEffortValue(String newValue) {
    int effVal = validate.effortValue(newValue);
    switch (effVal) {
      case 0:   // Effort Value is valid
        return null;
      case 1:
        return Controller.getTextLabel('error_message_EffVal1');
      case 2:
        return Controller.getTextLabel('error_message_EffVal2');
      default:
        return Controller.getTextLabel('error_message_unknownInput');
    }
  }

  String? validateEffortUnit(String newUnit) {
    if (validate.effortUnit(newUnit)) {
      return null;
    }
    else {
      return Controller.getTextLabel('error_message_EffUnit');
    }
  }

  String? validateExpirationDate(DateTime newDate) {
    if (validate.expirationDate(newDate)) {
      return null;
    } else {
      return Controller.getTextLabel('error_message_Date');
    }
  }

  String? validateAllInputs(ListItem item) {
    String? errorMessage = validateTitle(item.title);
    if (errorMessage != null) {
      return errorMessage;
    } else {
      errorMessage = validateEffortValue(item.effort_value);
      if (errorMessage != null) {
        return errorMessage;
      } else {
        errorMessage = validateEffortUnit(item.effort_unit);
        if (errorMessage != null) {
          return errorMessage;
        } else {
          errorMessage = validateExpirationDate(item.expiration_date);
          if (errorMessage != null) {
            return errorMessage;
          } else {
            return null;
          }
        }
      }
    }
  }

  bool addItem(ListItem newItem) {
    if (itemList.add(newItem)){
      return true;
    }
    else{
      return false;
    }
  }

  void removeItem(ListItem item){
    itemList.remove(item);
  }
}
