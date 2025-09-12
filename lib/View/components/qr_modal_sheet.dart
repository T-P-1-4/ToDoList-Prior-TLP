import 'package:flutter/material.dart';
import 'package:todo_appdev/Controller/controller.dart';
import 'package:todo_appdev/Model/qr_code_manager.dart';

class QrModalSheet extends StatefulWidget {
  const QrModalSheet({super.key});

  @override
  State<QrModalSheet> createState() => _QrModalSheetState();
}

class _QrModalSheetState extends State<QrModalSheet> {
  bool isGenerating = false;
  bool isScanning = false;
  String? scannedData;
  Future<Widget>? qrFuture;

  @override
  void initState() {
    super.initState();
    scan();
  }

  void generate() {
    setState(() {
      isGenerating = true;
      isScanning = false;
      scannedData = null;
      qrFuture = Controller.getQrCode();
    });
  }

  void scan() {
    setState(() {
      isGenerating = false;
      isScanning = true;
      scannedData = null;
      qrFuture = null;
    });
  }

  void onScan(String code) async{
    List<String> s = code.split("\n");
    await Controller.popMagenta(s[1],s[0],s[2], context);

    // Close Modal-Bottom sheet wenn erfolgreich qr code gescannt und gebe SnackBar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Controller.getTextLabel('QR_Code_Success')),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }

    setState(() {
      scannedData = code;
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Text(
              Controller.getTextLabel("Settings_QR"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: scan,
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.black54),
                    label: Text(Controller.getTextLabel('QR_Code_Scan'),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: generate,
                    icon: const Icon(Icons.qr_code, color: Colors.black54),
                    label: Text(Controller.getTextLabel('QR_Code_Generate'),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: isScanning
                    ? buildQrScanner(onScan)
                    : qrFuture != null
                    ? FutureBuilder<Widget>(
                  future: qrFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('${Controller.getTextLabel('QR_Code_Error')}: ${snapshot.error}');
                    } else {
                      return snapshot.data!;
                    }
                  },
                )
                    : buildQrScanner(onScan),
              ),
            ),
            if (scannedData != null)
              Text("${Controller.getTextLabel('QR_Code_Recognized')}: $scannedData"),
          ],
        ),
      ),
    );
  }
}
