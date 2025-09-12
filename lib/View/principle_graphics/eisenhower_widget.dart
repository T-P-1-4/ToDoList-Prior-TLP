import 'package:flutter/material.dart';
import '../../Controller/controller.dart';

class EisenhowerWidget extends StatelessWidget {
  const EisenhowerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        'label': Controller.getTextLabel('highUrgencyHighPriority'),
        'score': 3,
      },
      {
        'label': Controller.getTextLabel('mediumUrgencyMediumPriority'),
        'score': 10,
      },
      {
        'label': Controller.getTextLabel('lowUrgencyLowPriority'),
        'score': 25,
      },
    ];

    final color = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Controller.getTextLabel('sortedByUrgencyPriority'),
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
                  Icon(Icons.trending_down, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${task['label']} (${Controller.getTextLabel('score')}: ${task['score']})',
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
