class DataFrame {
  List<Map<String, String>> df = [];

  DataFrame(){
    if (!df.isEmpty){
        df = [];
    }
  }

  void addRow(String id, String value) {
    df.add({'id': id, 'value': value});
  }

  void deleteRow(String id){
    df.removeWhere((row) => row['id'] == id);
  }

  String getRow(String id) {
    String value = df.firstWhere((row) => row['id'] == id)['value'].toString() ;
    return  (!value.isEmpty)? value:"";
  }

  String toCsv() {
    if (df.isEmpty) return 'id,value';
    final header = df.first.keys.join(';');
    final values = df.map((row) => row.values.join(';')).join('\n');
    return '$header\n$values';
  }

  void csvToDataFrame(String csv) {
    final lines = csv.trim().split('\n');
    final header = lines.first.split(';');

    for (int i = 1; i < lines.length; i++) {
      var line = lines[i].split(';');
      var id = line[0];
      var val = line[1];
      addRow(id, val);
    }
  }
}
