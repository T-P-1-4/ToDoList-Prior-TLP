import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'magenta_cloud_connection.dart';

/// Baut einen QR-Code aus den Daten der getQrData()-Funktion.
QrImageView buildQrCode() {
  List<String> l = getQrData();
  String s = l.join("\n");
  for (var line in l) {
    print(line);
  }
  print(s);
  return QrImageView(
    data: s,
    version: QrVersions.auto,
    size: 320,
    gapless: true,
  );
}

Widget buildQrScanner(void Function(String) onScan) {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  return StatefulBuilder(
    builder: (context, setState) {
      void onQRViewCreated(QRViewController qrController) {
        controller = qrController;
        controller!.scannedDataStream.listen((scanData) {
          onScan(scanData.code ?? '');
          controller?.pauseCamera(); // nach Scan stoppen
        });
      }

      void reassembleCamera() {
        if (Platform.isAndroid) {
          controller?.pauseCamera();
        } else if (Platform.isIOS) {
          controller?.resumeCamera();
        }
      }

      // Wichtig für Hot Reload in Android/iOS
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reassembleCamera();
      });

      return Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
            ),
          ),
        ],
      );
    },
  );
}
