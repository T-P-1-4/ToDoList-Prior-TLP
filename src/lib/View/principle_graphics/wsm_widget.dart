import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../Controller/controller.dart';

class WsmWidget extends StatelessWidget {
  final List<int> weights;

  const WsmWidget({super.key, required this.weights});

  @override
  Widget build(BuildContext context) {
    final labels = [
      Controller.getTextLabel('priority'),
      Controller.getTextLabel('duration'),
      Controller.getTextLabel('deadline')
    ];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Controller.getTextLabel('weightedScoring'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.4,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: List.generate(3, (i) {
                return PieChartSectionData(
                  value: weights[i].toDouble(),
                  title: '${labels[i]} (${weights[i]}%)',
                  color: theme.colorScheme.primary.withOpacity(0.3 + i * 0.2),
                  titleStyle: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
