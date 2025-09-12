import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controller/controller.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Model/app_data.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final statsController = Controller.getStatsController(context);
    statsController.load(Provider.of<AppData>(context, listen: false));
    final stats = statsController.model;

    final weekdayMap = Controller.getWeekdayCompletion(context);
    final busiestDay = weekdayMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final sortedEntries = weekdayMap.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final detailedPrioStats = stats.getDetailedPriorityStats();

    return Scaffold(
      backgroundColor: color.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              Controller.getTextLabel('Stats_Title'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.onSurface),
            ),
          ),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildInfoCard(
                  context,
                  icon: Icons.check_circle,
                  color: color.primary,
                  title: Controller.getTextLabel("Stats_Completed"),
                  value: "${statsController.lifetime.checkedCount} / ${statsController.lifetime.createdCount}",
                  subtitle: "${stats.getUncheckedTasks()} ${Controller.getTextLabel("Stats_Tasks_Open")}"
              ),
              _buildInfoCard(
                  context,
                  icon: Icons.timer,
                  color: color.secondary,
                  title: Controller.getTextLabel("Stats_AvgDuration"),
                  value: "${stats.getAverageDuration().toStringAsFixed(1)} h"
              ),
              _buildInfoCard(
                  context,
                  icon: Icons.percent,
                  color: color.primaryContainer,
                  title: Controller.getTextLabel("Stats_CompletionRate"),
                  value: "${(stats.getCompletionRate() * 100).toStringAsFixed(1)} %"
              ),
              _buildInfoCard(
                  context,
                  icon: Icons.calendar_today,
                  color: color.tertiary,
                  title: Controller.getTextLabel("Stats_Busiest_Day"),
                  value: busiestDay
              ),

              Container(
                constraints: const BoxConstraints(minHeight: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: color.secondary.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 32, color: color.secondary),
                    const SizedBox(height: 8),
                    Text(
                      Controller.getTextLabel("Stats_Weekday_Title"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final labels = sortedEntries.map((e) => e.key).toList();
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        labels[value.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            barGroups: List.generate(sortedEntries.length, (index) {
                              final entry = sortedEntries[index];
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    width: 14,
                                    color: color.secondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: color.primary.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart, size: 28, color: color.primary),
                    const SizedBox(height: 6),
                    Text(
                      Controller.getTextLabel("Stats_PrioSplit_Title"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 0.9,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 18,
                            sections: [1, 2, 3].map((prio) {
                              final total = detailedPrioStats[prio]?['total'] ?? 0;
                              final fullTotal = [1, 2, 3]
                                  .map((p) => detailedPrioStats[p]?['total'] ?? 0)
                                  .reduce((a, b) => a + b);
                              final percentage = fullTotal > 0 ? (total / fullTotal * 100).round() : 0;

                              final opacityByPrio = {
                                1: 0.3,
                                2: 0.6,
                                3: 1.0,
                              }[prio]!;

                              return PieChartSectionData(
                                value: total.toDouble(),
                                title: ['I', 'II', 'III'][prio - 1],
                                color: color.primary.withOpacity(opacityByPrio),
                                radius: 32,
                                titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
          if (subtitle != null)
            Text(subtitle, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}