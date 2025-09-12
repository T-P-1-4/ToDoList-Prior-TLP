import 'package:flutter/material.dart';
import 'package:todo_appdev/View/principle_graphics/duration_deadline_widget.dart';
import 'package:todo_appdev/View/principle_graphics/edd_widget.dart';
import 'package:todo_appdev/View/principle_graphics/eisenhower_widget.dart';
import 'package:todo_appdev/View/principle_graphics/own_priority_widget.dart';
import 'package:todo_appdev/View/principle_graphics/value_effort_widget.dart';
import 'package:todo_appdev/View/principle_graphics/wsm_widget.dart';
import '../Controller/controller.dart';
import '../Model/priority_enum.dart';
import '../View/components/wsm_dialog.dart';

class PrincipleView extends StatefulWidget {
  const PrincipleView({super.key});

  @override
  State<PrincipleView> createState() => _PrincipleViewState();
}

class _PrincipleViewState extends State<PrincipleView> {
  @override
  Widget build(BuildContext context) {
    final selected = Controller.getCurrentPrincipleEnum(context);
    final principles = PriorityEnum.values;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Controller.getTextLabel('Prio_IntroAtPage'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  Controller.getTextLabel('Prio_Info_Long_Press'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Kachelansicht der Prinzipien mit onLongPress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: principles.map((p) {
                final isSelected = selected == p;
                final backgroundColor = isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.08);
                final borderColor = isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent;

                return GestureDetector(
                  onTap: () {
                    Controller.setSelectedPrinciple(context, p);
                    Controller.writeHivePriority(p);
                    Controller.sortList(context, p.value);
                    setState(() {});
                  },
                  onLongPress: () async {
                    if (p == PriorityEnum.WeightedScoringModel) {
                      await showDialog(
                        context: context,
                        builder: (context) => const WSMDialog(),
                      );
                      setState(() {});
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  p.label,
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          content: Text(_buildExplanation(p)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        p.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 32),

          // Visualisierung des aktuellen Prinzips
          if (selected == PriorityEnum.WeightedScoringModel)
            FutureBuilder<List<int>>(
              future: Controller.readHiveWSM(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.length == 3) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: WsmWidget(weights: snapshot.data!),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: _buildPrincipleGraphic(selected),
            ),
        ],
      ),
    );
  }

  Widget _buildPrincipleGraphic(PriorityEnum selected) {
    switch (selected) {
      case PriorityEnum.OwnPriority:
        return const OwnPriorityWidget();
      case PriorityEnum.EDD:
        return const EddWidget();
      case PriorityEnum.EisenhowerMatrix:
        return const EisenhowerWidget();
      case PriorityEnum.ValueEffort:
        return const ValueEffortWidget();
      case PriorityEnum.DurationDeadline:
        return const DurationDeadlineWidget();
      case PriorityEnum.WeightedScoringModel:
        return const SizedBox.shrink();
    }
  }

  String _buildExplanation(PriorityEnum selected) {
    switch (selected) {
      case PriorityEnum.OwnPriority:
        return Controller.getTextLabel('Prio_OwnPrio_Desc');
      case PriorityEnum.EDD:
        return Controller.getTextLabel('Prio_EDD_Desc');
      case PriorityEnum.EisenhowerMatrix:
        return Controller.getTextLabel('Prio_Eisenhower_Desc');
      case PriorityEnum.ValueEffort:
        return Controller.getTextLabel('Prio_ValueEffort_Desc');
      case PriorityEnum.DurationDeadline:
        return Controller.getTextLabel('Prio_DurationDeadline_Desc');
      case PriorityEnum.WeightedScoringModel:
        return Controller.getTextLabel('Prio_WSM_Desc');
    }
  }
}
