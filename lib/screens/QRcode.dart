import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({Key? key}) : super(key: key);

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> with WidgetsBindingObserver {
  late final MobileScannerController controller;
  StreamSubscription<Object?>? _subscription;
  String? result;
  bool _dialogShown = false;
  bool _isScannerActive = false;

  @override
  void initState() {
    super.initState();

    // Initialize the MobileScannerController
    controller = MobileScannerController();

    // Listen to lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Start listening to scanner events
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Start the scanner
    _startScanner();
  }

  Future<void> _startScanner() async {
    try {
      await controller.start();
      setState(() {
        _isScannerActive = true;
      });
    } catch (e) {
      print("Error starting the scanner: $e");
    }
  }

  Future<void> _stopScanner() async {
    await controller.stop();
    setState(() {
      _isScannerActive = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isScannerActive) {
          _startScanner();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _subscription?.cancel();
        _stopScanner();
        break;
      default:
        break;
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (!_dialogShown && barcode.rawValue != null) {
      setState(() {
        result = barcode.rawValue!;
        _dialogShown = true;
      });
      _showQRCodeReceivedDialog(result!);
    }
  }

  void _showQRCodeReceivedDialog(String qrContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR code reçu'),
          content: Text('Contenu du QR Code : $qrContent'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _dialogShown = false;
                  result = null;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _subscription?.cancel();
    await controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_isScannerActive) {
                    _stopScanner();
                  } else {
                    _startScanner();
                  }
                },
                child: const Text('Scanner un QR code'),
              ),
            ),
          ),
          if (result != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Contenu du QR Code : $result'),
            ),
        ],
      ),
    );
  }
}
