import 'package:flutter/material.dart';
import '../Controller/controller.dart';
import '../Model/list_item.dart';
import 'show_message_view.dart';

/*
the popup is for adding and editing an item
 */

DateTime today = DateTime.now();
String todayString = today.toString().split('T')[0];

class PopupView extends StatefulWidget {
  final ListItem? itemToEdit;

  const PopupView({super.key, this.itemToEdit});

  static void open(BuildContext context, {ListItem? itemToEdit}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => PopupView(itemToEdit: itemToEdit),
      ),
    );
  }

  @override
  State<PopupView> createState() => _PopupViewState();
}

class _PopupViewState extends State<PopupView> {
  final PageController pageController = PageController();
  late ListItem newItem;
  late bool isEditMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.itemToEdit != null) {
      // Item wird bearbeitet
      newItem = widget.itemToEdit!;
      isEditMode = true;
    }
    else {
      // Item wird neu erstellt
      newItem = ListItem(["", "", "1", "0", "min", todayString]);
      isEditMode = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Controller.getCurrentColor(context);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 350,
            height: 420,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Controller.getTextLabel(isEditMode ? 'popup_EditNote' : 'popup_AddNote'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Divider(thickness: 2, height: 1, color: colorScheme.primary.withOpacity(0.8)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: close,
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPage1(itemToEdit: newItem),
                      _buildPage2(itemToEdit: newItem),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage1({ListItem? itemToEdit}) {
    final listItemController = Controller.itemList(context);
    final buttonTextStyle = const TextStyle(fontSize: 16);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // display title
                _buildTextField(
                  Controller.getTextLabel("popup_Title"),
                  20,
                  1,
                  TextInputType.text,
                      (value) {
                    setState(() {
                      newItem.title = value;
                    });
                    String? errorMessage = listItemController.validateTitle(value);
                    if (errorMessage != null) {
                      showNotifyMessage(context, errorMessage); // show error message because entered title is not valid
                    }
                  },
                  newItem.title,
                ),
                const SizedBox(height: 16),

                // display description
                _buildTextField(
                  Controller.getTextLabel("popup_description"),
                  200,
                  null,
                  TextInputType.text,
                      (value) {
                    setState(() {
                      newItem.description = value;
                    });
                  },
                  newItem.description,
                  minLines: 1,
                ),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                String? errorMessage = listItemController.validateTitle(newItem.title);
                if (errorMessage != null) {
                  showNotifyMessage(context, errorMessage);
                } else {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                Controller.getTextLabel("popup_Next"),
                style: buttonTextStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildPage2({ListItem? itemToEdit}) {
    final listItemController = Controller.itemList(context);
    final buttonTextStyle = const TextStyle(fontSize: 16);

    return Column(
      children: [
        Expanded(
          child: StatefulBuilder(
            builder: (context, update) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // display due date
                    Row(
                      children: [
                        Text(Controller.getTextLabel("popup_Date"), style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 10),
                        Text(
                          '${newItem.expiration_date.toLocal()}'.split(' ')[0],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: today,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              String? errorMessage = listItemController.validateExpirationDate(picked);
                              if (errorMessage != null) {
                                showNotifyMessage(context, errorMessage);
                              } else {
                                setState(() {
                                  newItem.expiration_date = picked;
                                });
                              }
                            }
                          },
                          child: Text(Controller.getTextLabel("popup_ChooseDate")),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // display effort and effort unit (text field and dropdown menu)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            Controller.getTextLabel("popup_Effort"),
                            3,
                            1,
                            TextInputType.number,
                                (value) {
                              setState(() {
                                newItem.effort_value = value;
                              });
                              String? errorMessage = listItemController.validateEffortValue(value);
                              if (errorMessage != null) {
                                showNotifyMessage(context, errorMessage);
                              }
                            },
                            newItem.effort_value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: newItem.effort_unit,
                            decoration: const InputDecoration(border: InputBorder.none),
                            items: [
                              DropdownMenuItem(
                                value: 'min',
                                child: Text(
                                  Controller.getTextLabel("popup_minutes"),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'h',
                                child: Text(
                                  Controller.getTextLabel("popup_hours"),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'd',
                                child: Text(
                                  Controller.getTextLabel("popup_days"),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                String? errorMessage = listItemController.validateEffortUnit(value);
                                if (errorMessage != null) {
                                  showNotifyMessage(context, errorMessage);
                                } else {
                                  setState(() {
                                    newItem.effort_unit = value;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // display importance (three-position slider)
                    _buildSlider(Controller.getTextLabel("popup_Importance"), newItem.priority, (val) {
                      setState(() {
                        newItem.priority = val;
                      });
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  Controller.getTextLabel("popup_Back"),
                  style: buttonTextStyle,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? errorMessage = listItemController.validateAllInputs(newItem);
                  if (errorMessage != null) {
                    showNotifyMessage(context, errorMessage);
                  } else {
                    newItem.duration_time_in_hours = ListItem.toHours(newItem.effort_value, newItem.effort_unit);
                    isEditMode ? Controller.updateListItem(context, newItem): Controller.addListItem(context, newItem);
                    await Controller.writeHiveItem(newItem);
                    close();
                  }
                },
                child: Text(
                  isEditMode ? Controller.getTextLabel("popup_Save") : Controller.getTextLabel("popup_Add"),
                  style: buttonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSlider(String label, int current, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $current'),
        Slider(
          value: current.toDouble(),
          min: 1,
          max: 3,
          divisions: 2,
          label: current.toString(),
          onChanged: (val) => onChanged(val.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:  [
            Text(Controller.getTextLabel("popup_LowPrio"), style: TextStyle(fontSize: 12)),
            Text(Controller.getTextLabel("popup_HighPrio"), style: TextStyle(fontSize: 12)),
          ],
        ),

      ],
    );
  }

  static Widget _buildTextField(
      String label,
      int maxLength,
      int? maxLines,
      TextInputType keyboardType,
      ValueChanged<String> onChanged,
      String valueTextField, {
        int minLines = 1,
      }) {
    return TextFormField(
      initialValue: valueTextField,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14),
        border: UnderlineInputBorder(),
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}

