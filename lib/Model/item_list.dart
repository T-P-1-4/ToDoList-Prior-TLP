import 'package:flutter/cupertino.dart';
import 'package:time/time.dart';
import '../Controller/controller.dart';
import 'list_item.dart';

class ItemList extends ChangeNotifier{
  List<ListItem> l = []; // init empty list

  List<ListItem> get items => l;


  bool add(ListItem i){
    
    if (!contains(i)){ // if not already in list
      l.add(i);
      notifyListeners();
      return true;
    }
    return false;
  }
  
  ListItem remove(ListItem i){
    DateTime key_ts = i.getCreatedTimestamp;
    if (contains(i)){
      for (int i = 0; i < l.length;i++){
        if (l[i].getCreatedTimestamp== key_ts){
          ListItem value = l[i].getListItemObject;
          l.remove(l[i]);
          return value;
        }
      } 
    }
    throw Exception("Item not in list cant remove from list");
  }
  
  
  bool contains(ListItem i){
    DateTime key_ts = i.getCreatedTimestamp;
    for (int i = 0; i < l.length;i++){
      if (l[i].getCreatedTimestamp== key_ts) return true;
    }
    return false;
  }
  
  String dump(){
    String value = "";
    for (int i=0;i<l.length;i++){
      value += l[i].toString();
    }
    return value;
  }

  Future<void> orderList(int prio_order) async {
    switch (prio_order) {
      case 0:
        sortOwnPriority();
        break;
      case 1:
        sortEDD();
        break;
      case 2:
        sortEisenhowerMatrix();
        break;
      case 3:
        sortValueEffort();
        break;
      case 4:
        sortDurationDeadline();
        break;
      case 5:
        await sortWeightedScoringModel();
        break;
    }
    notifyListeners();
  }

  void sortOwnPriority(){
    List<ListItem> max_prio = [];
    List<ListItem> mid_prio = [];
    List<ListItem> min_prio = [];
    for (int i = 0; i < l.length;i++){
      if(l[i].getPriority == 3) max_prio.add(l[i]);
      if(l[i].getPriority == 2) mid_prio.add(l[i]);
      if(l[i].getPriority == 1) min_prio.add(l[i]);
    }
    List<ListItem> sortedList = [];
    sortedList.addAll(max_prio);
    sortedList.addAll(mid_prio);
    sortedList.addAll(min_prio);

    l = sortedList;
  }

  void sortEDD(){ // erliest due day
    Map<int, List<ListItem>> map = {}; // key = due date as days to deadline and list of items
    DateTime date = DateTime.now().date;
    for (int i = 0; i < l.length;i++){
      DateTime item = l[i].getExpirationDate.date;
      Duration difference = date.difference(item);
      int days = difference.inDays;
      if (!map.containsKey(days)) {
        map[days] = []; //init list
      }
      map[days]!.add(l[i]);
    }

    List<ListItem> sortedList = [];
    var sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a)); // absteigend
    for (var key in sortedKeys) {
      sortedList.addAll(map[key]!);
    }

    l = sortedList;
  }

  void sortEisenhowerMatrix(){
    Map<int, List<ListItem>> map = {}; // key = matrixValue as int and list of items
    DateTime date = DateTime.now();
    for (int i = 0; i < l.length;i++){
      DateTime item = l[i].getExpirationDate.date;
      Duration difference = date.difference(item);
      // Calculation is (difference in days³ + 1) * priority and then sort from low to high
      // example: days = 0, priority = 3 matrixValue = 3
      //          days = 1, priority = 3 matrixValue = 6
      //          days = 2, priority = 2 matrixValue = 18
      //          days = -2, priority = 2 matrixValue = -14 //expired dates are mor importent than others
      //          days = x, priority = p matrixValue = (x³+1)*p
      int matrixValue = 0;
      if (difference.inHours > 0 && difference.inDays == 0){
        matrixValue = (1 +1) * l[i].getPriority;
      }else if (item.isBefore(date.date)){
        matrixValue = (-difference.inDays  * difference.inDays * difference.inDays +1) * l[i].getPriority;
      }
      else{
        matrixValue = (difference.inDays  * difference.inDays * difference.inDays +1) * l[i].getPriority;
      }

      if (!map.containsKey(matrixValue)) {
        map[matrixValue] = []; //init list
      }
      map[matrixValue]!.add(l[i]);
    }

    List<ListItem> sortedList = [];
    var sortedKeys = map.keys.toList()..sort(); // aufsteigend
    for (var key in sortedKeys) {
      sortedList.addAll(map[key]!);
    }

    l = sortedList;
  }

  void sortValueEffort(){
    Map<double, List<ListItem>> map = {}; // key = value as int and list of items
    for (int i = 0; i < l.length;i++){
      // calculate so that the lowest value is the item with the most Value/Effort (turn priority)
      // example: duration = 0.5, priority = 3 value = 0.5
      //          duration = 0.5, priority = 2 value = 1.0
      //          duration = 0.5, priority = 1 value = 1.5
      //          duration = d,   priority = p value = (4-p) * d
      double value = (4-l[i].getPriority) * l[i].getDurationTimeInHours;

      if (!map.containsKey(value)) {
        map[value] = []; //init list
      }
      map[value]!.add(l[i]);
    }

    List<ListItem> sortedList = [];
    var sortedKeys = map.keys.toList()..sort(); // aufsteigend
    for (var key in sortedKeys) {
      sortedList.addAll(map[key]!);
    }

    l = sortedList;
  }

  /// Sortiert die Liste nach einer Kombination aus Aufgabendauer und Deadline.
  /// Kürzere Aufgaben mit näheren Fristen werden bevorzugt. -> Text aus der Beschreibung (kleines info i) in Prio Page
  /// So ist es dann auch implementiert.
  /// -> kleine Aufgaben, die bald fertig sein müssen werden bevorzugt!
  void sortDurationDeadline() {
    // Aktuelles Datum für die Deadline Berechnung
    DateTime now = DateTime.now();

    // sort Funktion in Dart ist TimSort O(n log n)
    l.sort((a, b) {
      // Dauer der verglichenen Items in Stunden
      double durationA = a.getDurationTimeInHours;
      double durationB = b.getDurationTimeInHours;

      // Fristen in Tagen, bis zur Deadline
      int deadlineA = a.getExpirationDate
          .difference(now)
          .inDays;
      int deadlineB = b.getExpirationDate
          .difference(now)
          .inDays;

      // Kürzere Aufgabe + näher an deadline = kleinere Punktzahl -> weiter oben in Liste
      // Mehr Fokus auf Deadline, also mehr Gewichtung.
      // Durch Multiplikation mit festen Gewichten wird der Einfluss der Faktoren gesteuert.
      double scoreA = durationA * 0.5 + deadlineA * 1.0;
      double scoreB = durationB * 0.5 + deadlineB * 1.0;

      // Vergleichen der Scores: kleineren zuerst.
      return scoreA.compareTo(scoreB);
    });
  }

  /// Sortiert Aufgaben anhand gewichteter Benutzerkriterien: Priorität, Dauer, Deadline.
  /// Die Gewichtungen werden über Hive geladen und konnten davor vom User eingestellt werden.
  /// Priorität: Wert (1 - 3)
  /// Dauer: in Stunden
  /// Deadline: in Tagen
  /// -> Vorgehen nach Gewichtungen, die der Nutzer vorher für diese Drei Variablen eingestellt hat.
  Future<void> sortWeightedScoringModel() async {
    // Liest die Gewichtungen aus Hive: [prioWeight, durationWeight, deadlineWeight]
    List<int> weights = await Controller.readHiveWSM();

    // Abbruchkriterium: Wenn keine 3 Werte kommen, dann abbrechen
    if (weights.length != 3) {
      print("Ungütlige WSM-Gewichte. Erwartet [prio, duration, deadline].");
      return;
    }

    // Extrahieren der drei Gewichte
    int wPrio = weights[0];
    int wDur = weights[1];
    int wDead = weights[2];

    DateTime now = DateTime.now();

    // Normierungswerte vorbereiten - verhindert. Dass eine Aufgabe alles dominiert.
    int maxPrio = 3;

    double maxDur = l.map((item) => item.getDurationTimeInHours).fold(
        0.0, (a, b) => a > b ? a : b);

    int maxDead = l.map((item) => item.getExpirationDate.difference(now)
        .inDays).fold(0, (a, b) => a > b ? a : b);

    // Vermeiden Division durch 0, falls alle Werte gleich / leer sind
    if (maxDur == 0.0) maxDur = 1.0;
    if (maxDead == 0) maxDead = 1;

    // Sortiert nach berechnetem Score
    l.sort((a, b) {
      double prioA = a.getPriority.toDouble();
      double prioB = b.getPriority.toDouble();

      double durA = a.getDurationTimeInHours;
      double durB = b.getDurationTimeInHours;

      int deadA = a.getExpirationDate.difference(now).inDays;
      int deadB = b.getExpirationDate.difference(now).inDays;

      // Je höher der Score, desto weiter oben in der Liste
      // Die Werte werden zuerst normiert auf 0-1, dann mit Gewichten multipliziert.
      double scoreA = (prioA / maxPrio) * wPrio +
          ((maxDur - durA) / maxDur) * wDur +
          ((maxDead - deadA) / maxDead) * wDead;

      double scoreB = (prioB / maxPrio) * wPrio +
          ((maxDur - durB) / maxDur) * wDur +
          ((maxDead - deadB) / maxDead) * wDead;

      return scoreB.compareTo(scoreA);
    });
  }
}
