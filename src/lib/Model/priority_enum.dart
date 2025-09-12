import '../Controller/controller.dart';

enum PriorityEnum {
  OwnPriority(0),
  EDD(1),
  EisenhowerMatrix(2),
  ValueEffort(3),
  DurationDeadline(4),
  WeightedScoringModel(5);

  final int value;
  const PriorityEnum(this.value);

  factory PriorityEnum.fromInt(int i) {
    return PriorityEnum.values.firstWhere(
          (e) => e.value == i,
      orElse: () => throw ArgumentError('Invalid int for PriorityEnum: $i'),
    );
  }

  String get label {
    switch (this) {
      case PriorityEnum.OwnPriority:
        return Controller.getTextLabel('Prio_OwnPrio');
      case PriorityEnum.EDD:
        return Controller.getTextLabel('Prio_EDD');
      case PriorityEnum.EisenhowerMatrix:
        return Controller.getTextLabel('Prio_Eisenhower');
      case PriorityEnum.ValueEffort:
        return Controller.getTextLabel('Prio_ValueEffort');
      case PriorityEnum.DurationDeadline:
        return Controller.getTextLabel('Prio_DurationDeadline');
      case PriorityEnum.WeightedScoringModel:
        return Controller.getTextLabel('Prio_WSM');
    }
  }
}
