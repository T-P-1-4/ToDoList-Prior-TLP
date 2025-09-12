import 'dart:math';
import 'dart:convert';

class Crypto {
  static String createKey() {
    final t = DateTime.now().microsecondsSinceEpoch;
    final r = Random().nextInt(9000) + 1000; // 1000–9999
    final raw = '$t$r';

    final key = List.generate(raw.length, (i) {
      final code = (raw.codeUnitAt(i) + i) % 94 + 33;
      return String.fromCharCode(code);
    }).join();

    return key;
  }

  static String encodeValue(String value, String key) {
    final encodedChars = List.generate(value.length, (i) {
      final vChar = value.codeUnitAt(i);
      final kChar = key.codeUnitAt(i % key.length);
      return String.fromCharCode(vChar ^ kChar);
    }).join();

    final bytes = utf8.encode(encodedChars);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String decodeValue(String hexValue, String key) {
    final bytes = <int>[];
    for (var i = 0; i < hexValue.length; i += 2) {
      final hexByte = hexValue.substring(i, i + 2);
      bytes.add(int.parse(hexByte, radix: 16));
    }

    final decodedStr = utf8.decode(bytes);

    final decoded = List.generate(decodedStr.length, (i) {
      final dChar = decodedStr.codeUnitAt(i);
      final kChar = key.codeUnitAt(i % key.length);
      return String.fromCharCode(dChar ^ kChar);
    }).join();

    return decoded;
  }

  static String getChecksum(String hexValue){
    int checksum = 0;
    for (var i = 0; i < hexValue.length; i += 2) {
      final byte = int.parse(hexValue.substring(i, i + 2), radix: 16);
      checksum = (checksum + byte) % 100000; // 5 stellige chceksum modulo in schleife falls überlauf durch zu große datenmengen
    }
    return checksum.toString().padLeft(5, '0'); // mit nullen auffüllen"00123"
  }
}
