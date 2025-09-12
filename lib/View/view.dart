import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_appdev/View/navigation_view.dart';
import 'package:todo_appdev/View/principle_view.dart';
import 'package:todo_appdev/View/settings_view.dart';
import 'package:todo_appdev/View/statistics_view.dart';
import '../Controller/colors.dart';
import '../Controller/controller.dart';
import '../Model/navigation_item.dart';
import 'homepage.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Widget _buildContent(NavigationItem currentPage) {
    switch (currentPage) {
      case NavigationItem.mainPage:
        return const HomePage();
      case NavigationItem.statistics:
        return const StatisticsView();
      case NavigationItem.selectPrinciple:
        return const PrincipleView();
      case NavigationItem.settings:
        return const SettingsView();
      default:
        return const Center(child: Text("Unbekannte Seite."));
    }
  }


  @override
  Widget build(BuildContext context) {
    final selectedItem = Controller.getCurrentNavigationItem(context);
    final colorScheme = Provider.of<AppColorController>(context).currentColorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(Controller.getTextLabel('App_Name')),
      ),
      drawer: const NavigationView(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(selectedItem),
      ),
    );
  }
}