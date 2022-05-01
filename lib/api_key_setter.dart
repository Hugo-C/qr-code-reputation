import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_reputation/main.dart';
import 'package:qr_code_reputation/virus_total.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiKeySetter extends StatelessWidget {
  const ApiKeySetter({Key? key}) : super(key: key);

  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR code reputation tool',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const QRScan(),
    );
  }
// #enddocregion build
}

class _QRScanState extends State<QRScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _setApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(vtAPIKeyPref, result!.code!);

    // Return to the main page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainApp()),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    var buttonText = 'Scan the qr code containing your API key';
    var isQrCodeFound = result != null && result!.format == BarcodeFormat.qrcode;
    if (isQrCodeFound) {
      buttonText = 'Register this VT API KEY : ${result!.code?.substring(0, 4)}xxx';
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: ElevatedButton(
                  style: style,
                  onPressed: isQrCodeFound ? _setApiKey : null,
                  child: Text(buttonText),
                )
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class QRScan extends StatefulWidget {
  const QRScan({Key? key}) : super(key: key);

  @override
  _QRScanState createState() => _QRScanState();
}
