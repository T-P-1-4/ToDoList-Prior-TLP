import 'package:flutter/material.dart';
import '../Controller/controller.dart';
import '../Model/app_data.dart';
import '../Model/list_item.dart';
import 'check_item.dart';
import 'homepage.dart';

/*
A styled tile widget for displaying a to-do list item in the homepage screen.
On tap, it is showing the item's status, priority, expiration, and further details.
 */

class ListItemTile extends StatelessWidget {
  const ListItemTile({
    super.key,
    required this.listItem,
    required this.colorP,
  });

  final ListItem listItem;
  final Color colorP;

  @override
  Widget build(BuildContext context) {
    final listItemController = Controller.itemList(context);
    bool isExpired = listItemController.validateExpirationDate(listItem.expiration_date) != null;

    final colorScheme = Controller.getCurrentColor(context);
    Color colorPrio = colorP;

    if(colorP == Colors.grey) {   // OwnPriority
      switch (listItem.priority) {
        case 1:
          colorPrio = Colors.green;
          break;
        case 2:
          colorPrio = Colors.yellow;
          break;
        case 3:
          colorPrio = Colors.red;
          break;
        default:
          colorPrio = colorP;
      }
    }

    AppData appData = AppData();
    appData.unchecked = Controller.getUncheckedList(context);
    appData.checked = Controller.getCheckedList(context);

    List<String> durationParts = ListItem.hoursToString(listItem.duration_time_in_hours);
    double value = double.tryParse(durationParts[0]) ?? 0;
    String valueString = value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();

    String duration = '$valueString ${durationParts[1]}';

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: listItem.isChecked
                ? [
              Colors.grey.shade500.withOpacity(0.75),
              Colors.grey.shade500.withOpacity(0.75),
            ]
                : isExpired
                ? [
              Colors.red.shade400.withOpacity(0.8),
              Colors.red.shade400.withOpacity(1.0),
            ]
                : [
              colorScheme.primary.withOpacity(0.75),
              colorScheme.primary.withOpacity(1.0),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpired
                ? listItem.isChecked
                    ? Colors.black12
                    : Colors.red.shade600
                : Colors.black12,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),

        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // GestureDetector
          leading: CheckCircle(listItem: listItem),
          title: Text(
            listItem.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: listItem.isChecked
                  ? Colors.black54
                  : colorScheme.onPrimary,
              decoration: listItem.isChecked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),

          // Anzeige für Wichtigkeit (Symbol rechts im item)
          trailing: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              _getPrioIcon(colorPrio),
              color: isExpired
                ? Color(0xFF8B0000)
                : colorPrio,
              size: 35,
            ),
          ),

          onTap: () async{
            // Dialog öffnen mit Details zu dem listItem
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              listItem.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(thickness: 1, height: 1, color: Colors.grey),
                    ],
                  ),
                ),
                content:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Controller.getTextLabel("popup_description"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listItem.description.isEmpty
                          ? Controller.getTextLabel("itemDetails_NoDescription")
                          : listItem.description,
                      style: const TextStyle(fontSize: 14),
                    ),

                    // Anzeige von Datum, Aufwand und Wichtigkeit im Details-Popup
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.calendar_today, Controller.getTextLabel("popup_Date"), '${listItem.expiration_date.toLocal()}'.split(' ')[0]),

                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.timer, Controller.getTextLabel("popup_Effort"), duration),

                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.priority_high, Controller.getTextLabel("popup_Importance"), listItem.priority.toString()),
                  ],
                ),
                  actions: [

                    // edit and delete button for unchecked items
                    if (!listItem.checked)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  openPopup(context, currentItem: listItem);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(2),
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(0, 48),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit, color: Colors.blue),
                                      const SizedBox(width: 6),
                                      Text(
                                        Controller.getTextLabel("Edit"),
                                        style: const TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Controller.deleteItem(context, listItem);
                                  Controller.deleteHiveItem(listItem);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(2),
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(0, 48),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete, color: Colors.red),
                                      const SizedBox(width: 6),
                                      Text(
                                        Controller.getTextLabel("Delete"),
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )

                    // just delete Button for checked items
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Controller.deleteItem(context, listItem);
                              Controller.deleteHiveItem(listItem);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.delete, color: Colors.red),
                                  const SizedBox(width: 6),
                                  Text(
                                    Controller.getTextLabel("Delete"),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]
              ),
            );
          },
        )
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

IconData? _getPrioIcon(Color colorPrio) {
  switch (colorPrio) {
    case Colors.grey:
      return null;

    case Colors.red:
      return Icons.error_outline;

    case Colors.yellow:
      return Icons.schedule;

    case Colors.green:
      return Icons.expand_circle_down_outlined;

    default:
      return null; // Fallback
  }
}