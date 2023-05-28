import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learningdart/views/scanning/scaning_view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer' as dev show log;

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final qrKey = GlobalKey();
  QRViewController? controller;
  Barcode? barcode;
  bool gotValidQR = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildQRView(context),
            Positioned(
              bottom: 10,
              child: buildResult(),
            )
          ],
        ),
      ));
  Widget buildResult() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), color: Colors.white24),
      child: Text(
        barcode != null ? 'Result :${barcode!.code}' : 'Scan a code',
        maxLines: 4,
      ),
    );
  }

  Widget buildQRView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: Colors.white24,
            borderRadius: 10,
            borderLength: 20,
            borderWidth: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.9),
      );
  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return ScanningView(value: '${scanData.code}');
        }),
      );

      controller.resumeCamera();
    });
  }
}
