import 'package:flutter/material.dart';
import '../../Controller/controller.dart';

class DurationDeadlineWidget extends StatelessWidget {
  const DurationDeadlineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    final tasks = [
      {
        'label': Controller.getTextLabel('shortUrgent'),
        'score': 2,
      },
      {
        'label': Controller.getTextLabel('mediumDurationModerateDeadline'),
        'score': 4,
      },
      {
        'label': Controller.getTextLabel('longFarDeadline'),
        'score': 7,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Controller.getTextLabel('sortedByDurationDeadline'),
          style: Theme.of(context).textTheme.titleMedium,
        ),const SizedBox(height: 12),
        Column(
          children: tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, size: 18, color: color),
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
