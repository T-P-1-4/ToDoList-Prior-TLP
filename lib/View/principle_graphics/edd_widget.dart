import 'package:flutter/material.dart';
import '../../Controller/controller.dart';

class EddWidget extends StatelessWidget {
  const EddWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final deadlines = [
      Controller.getTextLabel('today'),
      Controller.getTextLabel('tomorrow'),
      Controller.getTextLabel('nextWeek'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Controller.getTextLabel('sortedByDueDate'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Column(
          children: deadlines.map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${Controller.getTextLabel('due')}: $d – ${Controller.getTextLabel('taskX')}',
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
