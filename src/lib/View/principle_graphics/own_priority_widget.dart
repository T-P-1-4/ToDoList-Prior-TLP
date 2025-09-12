import 'package:flutter/material.dart';
import '../../Controller/controller.dart';

class OwnPriorityWidget extends StatelessWidget {
  const OwnPriorityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final priorities = [3, 2, 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Controller.getTextLabel('sortedByManualPriority'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Column(
          children: priorities.map((prio) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_drop_up, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${Controller.getTextLabel('priority')} $prio – ${Controller.getTextLabel('task')} ${String.fromCharCode(65 + (3 - prio))}',
                      style: Theme.of(context).textTheme.bodySmall,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
