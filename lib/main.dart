import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_reputation/api_key_setter.dart';
import 'package:qr_code_reputation/url_reputation.dart';
import 'package:qr_code_reputation/virus_total.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

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

class _QRScanState extends State<QRScan>  with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    // Check if VT API key is set, else ask for it
    SharedPreferences.getInstance().then((pref) {
    if (pref.getString(vtAPIKeyPref) == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ApiKeySetter()),
        );
  }});
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

  void _goToUrlReputation() {
    controller?.pauseCamera();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UrlReputation(url: result!.code!)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    var buttonText = 'Scan a qr code to begin';
    var isQrCodeFound = result != null && result!.format == BarcodeFormat.qrcode;
    if (isQrCodeFound) {
      buttonText = 'Ask VT about : ${result!.code}';  // TODO format
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
                onPressed: isQrCodeFound ? _goToUrlReputation : null,
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log(state.name);
    if (state == AppLifecycleState.resumed) {
      log("Resumed camera");
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}

class QRScan extends StatefulWidget {
  const QRScan({Key? key}) : super(key: key);

  @override
  _QRScanState createState() => _QRScanState();
}
