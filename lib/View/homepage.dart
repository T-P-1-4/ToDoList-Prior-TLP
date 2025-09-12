import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_appdev/Model/app_data.dart';
import 'package:todo_appdev/Model/list_item.dart';
import 'package:todo_appdev/View/popup.dart';
import '../Controller/controller.dart';
import 'build_itemList_homepage.dart';
import 'components/expandable_header.dart';

/*
this file creates the Home screen displaying expandable lists of not completed and completed items.
The items are sorted by priority and styled accordingly.
 */

DateTime today = DateTime.now();
String todayString = today.toString().split('T')[0]; //creating todayString considering just year and day

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _tasksIsExpanded = true;
  bool _completedIsExpanded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Controller.sortList(context, Controller.getPriorityController(context).value);
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title of unchecked list
              ExpandableHeader(
                isExpanded: _tasksIsExpanded,
                onToggle: () {
                  setState(() {
                    _tasksIsExpanded = !_tasksIsExpanded;
                  });
                },
                title: Controller.getTextLabel('home_ToDo'),
              ),

              // if header for not completed tasks is expanded: display list
              if (_tasksIsExpanded)
                Consumer<AppData>(
                  builder: (context, itemList, child) {
                    final items = itemList.unchecked.l;
                    int itemCount = items.length;
                    if (items.isEmpty) {
                      return Text(Controller.getTextLabel("home_NoTasksYet"));
                    }
                    return ListView.separated(
                      itemCount: itemCount,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemBuilder: (context, index) {
                        final priority = Controller.getCurrentPrincipleEnum(context).value;
                        Color colorPrio;

                        if (priority == 0) {
                          colorPrio = Colors.grey;
                        } else {
                          if (index < itemCount / 3) {
                            colorPrio = Colors.red;
                          } else if (index < 2 * itemCount / 3) {
                            colorPrio = Colors.yellow;
                          } else {
                            colorPrio = Colors.green;
                          }
                        }

                        return ListItemTile(listItem: items[index], colorP: colorPrio);
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                    );
                  },
                ),

              //Title of completed list
              ExpandableHeader(
                isExpanded: _completedIsExpanded,
                onToggle: () {
                  setState(() {
                    _completedIsExpanded = !_completedIsExpanded;
                  });
                },
                title: Controller.getTextLabel('home_Completed'),
              ),

              // if header for completed tasks is expanded: display list
              if (_completedIsExpanded)
                Consumer<AppData>(
                  builder: (context, itemList, child) {
                    final checkedItems = itemList.checked.l;
                    if (checkedItems.isEmpty) {
                      return Text(Controller.getTextLabel("home_NoCompletedTasks"));
                    }
                    return ListView.separated(
                      itemCount: checkedItems.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemBuilder: (context, index) =>
                          ListItemTile(listItem: checkedItems[index], colorP: Colors.transparent),
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      //Button for adding a task
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            openPopup(context);
          },
          child: const Icon(
            size: 48,
            Icons.add
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

void openPopup(BuildContext context, {ListItem? currentItem}) {
  PopupView.open(context, itemToEdit: currentItem);
}
