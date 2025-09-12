import 'package:flutter/material.dart';
import '../../Controller/controller.dart';

class ValueEffortWidget extends StatelessWidget {
  const ValueEffortWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        'label': Controller.getTextLabel('highValueLowEffort'),
        'value': 0.5,
      },
      {
        'label': Controller.getTextLabel('mediumValueEffort'),
        'value': 1.0,
      },
      {
        'label': Controller.getTextLabel('lowValueHighEffort'),
        'value': 2.0,
      },
    ];

    final color = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Controller.getTextLabel('sortedByValueEffort'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Column(
          children: tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.speed, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${task['label']} (${Controller.getTextLabel('score')}: ${task['value']})',
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
