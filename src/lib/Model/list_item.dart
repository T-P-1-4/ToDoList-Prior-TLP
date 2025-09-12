import 'dart:convert';


class ListItem {
  //Values from user input
  String title = '';
  String description = '';
  int priority = 1;
  String effort_value = '';
  String effort_unit = 'min';
  double duration_time_in_hours;
  DateTime expiration_date;

  //later added values due to ussage of checkbox
  DateTime checked_date = DateTime(1970);
  bool checked = false;

  //calculated Values
  DateTime created_ts;

  /* example List:
      ["Hund raus bringen",
      "gehe mit ihm ums haus",
      "3",
      "20", "min",
      "2025-05-06",
      ]

  */
  //Construct use as l[4] "min", "h" or "d"
  ListItem(List<String> l, {String? timeStamp}):
                            title = l[0],
                            description = l[1],
                            priority = int.parse(l[2]),
                            effort_value = l[3],
                            effort_unit = l[4],
                            duration_time_in_hours = toHours(l[3], l[4]),
                            expiration_date = toDate(l[5]),
                            created_ts = timeStamp != null ? DateTime.parse(timeStamp) : DateTime.timestamp();

  String get getTitle => title;

  String get getDescription => description;

  int get getPriority => priority;

  double get getDurationTimeInHours => duration_time_in_hours;

  DateTime get getExpirationDate => expiration_date;

  DateTime get getCheckedDate => checked_date;

  bool get isChecked => checked;

  DateTime get getCreatedTimestamp => created_ts;

  ListItem get getListItemObject => this;

  void setChecked() { this.checked = true; this.checked_date = DateTime.now();}
  void setUnchecked() { this.checked = false; this.checked_date = DateTime(1970);}

  static double toHours(String duration, String unit){
    if (unit == "min") return int.parse(duration)/60.0;
    if (unit == "h") return int.parse(duration)/1.0;
    if (unit == "d") return int.parse(duration)*24.0;
    throw Exception("Unexpected identifier, expected  unit as min, h or d");
  }

  static List<String> hoursToString(double h){
    if (h>24) return [(h/24).toString(), "d"];
    if (h<1) return [(h*60).toString(), "min"];
    return [h.toString(), "h"];
  }

  static DateTime toDate(String date){ // date has to be in format "yyyy-mm-dd"
  return DateTime.parse(date);
  }

  @override
  String toString(){
    return '''
      Title: $title
      Description: $description
      Priority: $priority
      Duration (hours): $duration_time_in_hours
      Expiration Date: $expiration_date
      Checked Date: $checked_date
      Checked: $checked
      Created Timestamp: $created_ts
    ''';
  }

  String toJsonString() {
    final map = {
      'title': title,
      'description': description,
      'priority': priority,
      'duration_time_in_hours': duration_time_in_hours,
      'expiration_date': expiration_date?.toString(),
      'checked_date': checked_date?.toString(),
      'checked': checked,
      'created_ts': created_ts?.toString(),
    };

    return jsonEncode(map);
  }

  factory ListItem.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr);
    List<String> hours = hoursToString(map['duration_time_in_hours']/1.0);
    List<String> s =   [map['title'],
      map['description'],
      map['priority'].toString(),
      double.parse(hours[0]).round().toString(), hours[1],
      map['expiration_date'],
    ];
    ListItem temp = ListItem(s,timeStamp: map['created_ts']);
    if (map['checked']== true){
      temp.checked = true;
      temp.checked_date = DateTime.parse(map['checked_date']);
    }
    return temp;
  }

}