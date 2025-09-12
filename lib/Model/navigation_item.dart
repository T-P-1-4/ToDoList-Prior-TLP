import '../Controller/controller.dart';

enum NavigationItem {
  mainPage,
  selectPrinciple,
  statistics,
  settings,
  qrCode,
}

extension NavigationItemExtension on NavigationItem {
  String get title {
    switch (this) {
      case NavigationItem.mainPage:
        return Controller.getTextLabel('Nav_Item_Main');
      case NavigationItem.selectPrinciple:
        return Controller.getTextLabel('Nav_Item_Select_Principles');
      case NavigationItem.statistics:
        return Controller.getTextLabel('Nav_Item_Stats');
      case NavigationItem.settings:
        return Controller.getTextLabel('Nav_Item_Settings');
      case NavigationItem.qrCode:
        return Controller.getTextLabel('Nav_Item_QR_Demo');
    }
  }
}