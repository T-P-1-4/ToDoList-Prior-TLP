import 'package:flutter/material.dart';
import '../Controller/controller.dart';
import '../Model/list_item.dart';

/*
This file displays a tappable check circle that toggles a to-do item's completion status and shows a fade animation when checked or unchecked.
 */

class CheckCircle extends StatefulWidget {
  final ListItem listItem;

  const CheckCircle({super.key, required this.listItem});

  @override
  State<CheckCircle> createState() => _CheckCircleState();
}

class _CheckCircleState extends State<CheckCircle> {
  bool? tempChecked;

  void handleTap() async {
    setState(() {
      tempChecked = !(widget.listItem.isChecked);
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.listItem.isChecked) {
      Controller.setItemUnchecked(context, widget.listItem);
    } else {
      Controller.setItemChecked(context, widget.listItem);
    }

    await Controller.writeHiveItem(widget.listItem);

    setState(() {
      tempChecked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isChecked = tempChecked ?? widget.listItem.isChecked;
    final colorScheme = Controller.getCurrentColor(context);

    return GestureDetector(
      onTap: handleTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isChecked ? 1.0 : 0.0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}