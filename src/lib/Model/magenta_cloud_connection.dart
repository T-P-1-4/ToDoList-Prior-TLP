import 'package:http/http.dart' as http;
import 'data_frame.dart';
import 'crypto.dart';
import 'package:flutter/services.dart' show rootBundle;

String TOKEN = "";
var url = Uri.https('magentacloud.de', '/remote.php/webdav/DB.csv');
var df;
var current_checksum;
var current_key;
var current_encoded_id;

List<String> getQrData(){
  List<String> l = [];
  if (current_key != ""){
  l = [current_key.toString(),current_encoded_id.toString(),current_checksum.toString()];
  }
  return l;
}

Future<String> loadToken() async {
  return await rootBundle.loadString('lib/config/magenta_cloud_token');
}

Future<bool> readCloud() async {
  TOKEN = await loadToken();
  var response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $TOKEN',
    },
  );

  if (response.statusCode.toString().startsWith("2")){
    df = DataFrame();
    df.csvToDataFrame(response.body);
    return true;
  }
  return false;
}

Future<bool> updateCloud(String value) async {
  if (await readCloud()){

    // create important values
    var time_id = DateTime.timestamp().toString();
    var k = Crypto.createKey();
    var encoded_id = Crypto.encodeValue(time_id, k);
    var encoded_val = Crypto.encodeValue(value, k);

    //Safe data for QR-Code
    current_encoded_id = encoded_id;
    current_key = k;
    current_checksum = Crypto.getChecksum(encoded_val);

    df.addRow(encoded_id,encoded_val);
    //print(df.toCsv());

    // update magenta cloud
    TOKEN = await loadToken();
    var response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $TOKEN',
      },
      body: df.toCsv(),
    );

    if (response.statusCode.toString().startsWith("2")){
      return true;
    }
  }
  return false;
}

Future<bool> deleteCloudEntry(String encoded_id) async {
  if (await readCloud()){
    df.deleteRow(encoded_id);

    //update new smaller data in cloud
    TOKEN = await loadToken();
    var response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $TOKEN',
      },
      body: df.toCsv(),
    );
    if (response.statusCode.toString().startsWith("2")){
      return true;
    }
  }
  return false;
}

Future<String> getCloudEntry(String encoded_id, String key, String checksum) async {

  String value = "";
  if (await readCloud()){
    value = df.getRow(encoded_id);
  }
  if (checksum == Crypto.getChecksum(value)){
    value = Crypto.decodeValue(value, key);
    return value;
  }else{
    return "";
  }
}
