import 'package:flutter/material.dart';
import '../Controller/controller.dart';
import '../Model/navigation_item.dart';
import 'package:todo_appdev/View/components/logo_widget.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedItem = Controller.getCurrentNavigationItem(context);

    // Drawer is a flutter Widget for Navigation-Bars
    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          Center(
            child: Column(
              children: [
                Container(
                  width: 160,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.7),
                        colorScheme.primary.withOpacity(0.3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: ColoredLogo(
                      color: colorScheme.primary,
                      size: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  Controller.getTextLabel('Menu_Name'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Take the first three entries in NavigationItem and display them
          Divider(color: colorScheme.outline),
          ...NavigationItem.values.take(3).map((item) {
            final isSelected = item == selectedItem;
            return Container(
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              child: ListTile(
                leading: Icon(_iconForItem(item), color: colorScheme.onSurface),
                title: Text(
                  item.title,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              subtitle: Text(
                _descriptionForItem(item),
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  ),
                ),
              onTap: () {
                Controller.selectNavigationItem(context, item);
                Navigator.pop(context);     // Close Drawer after selecting the wanted page
                },
              ),
            );
          }),

        Divider(color: colorScheme.outline),

        ...NavigationItem.values
        .where((item) => item == NavigationItem.settings)
        .map((item) {
          final isSelected = item == selectedItem;
          return Container(
            color: isSelected
              ? colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
            child: ListTile(
              leading: Icon(_iconForItem(item), color: colorScheme.onSurface),
              title: Text(
                item.title,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            subtitle: Text(
              _descriptionForItem(item),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.normal,
                ),
              ),
            onTap: () {
              Controller.selectNavigationItem(context, item);
              Navigator.pop(context);
              },
            ),
          );
        }),
        const Spacer(), // Platz nach Menüeinträgen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ColoredLogo(
                    color: colorScheme.primary,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 12),
                Text(Controller.getTextLabel('Menu_Motivation'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper-Method for creating Icons based on the Item in the Menu List
  IconData _iconForItem(NavigationItem item) {
    switch (item) {
      case NavigationItem.mainPage:
        return Icons.home;
      case NavigationItem.qrCode:
        return Icons.qr_code;
      case NavigationItem.statistics:
        return Icons.bar_chart;
      case NavigationItem.selectPrinciple:
        return Icons.lightbulb_outline;
      case NavigationItem.settings:
        return Icons.settings;
    }
  }

  // Helper-Method for creating descriptions for each Menu-Item
  String _descriptionForItem(NavigationItem item) {
    switch (item) {
      case NavigationItem.mainPage:
        return Controller.getTextLabel('Desc_Main');
      case NavigationItem.statistics:
        return Controller.getTextLabel('Desc_Stats');
      case NavigationItem.selectPrinciple:
        return Controller.getTextLabel('Desc_Select');
      case NavigationItem.settings:
        return Controller.getTextLabel('Desc_Settings');
      case NavigationItem.qrCode:
        return Controller.getTextLabel('Nav_Item_QR_Demo');
    }
  }
}