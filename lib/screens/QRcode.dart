import 'dart:async';
import 'dart:convert'; // Ajouté pour décoder le JSON
import 'package:flutter/material.dart';
import 'package:flutter_application_ap3/screens/delivery.dart';
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
    controller = MobileScannerController();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
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
      try {
        // Décodage du JSON pour extraire uniquement la référence
        final Map<String, dynamic> decoded = jsonDecode(barcode.rawValue!);
        final String reference = decoded["reference"] ?? '';

        if (reference.isNotEmpty) {
          setState(() {
            result = reference; // Stocke seulement la référence
            _dialogShown = true;
          });

          // Affiche le dialogue avec uniquement la référence
          _showQRCodeFoundDialog(result!);
        }
      } catch (e) {
        print("Erreur lors du traitement du QR code: $e");
      }
    }
  }

  Future<void> _showQRCodeFoundDialog(String reference) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Found'),
          content:
              Text('A QR code with reference "$reference" has been detected.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Ferme le dialogue

                // Arrête le scanner avant la navigation
                await _stopScanner();

                // Navigue vers la page DeliveryScreen avec la référence
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DeliveryScreen(initialReference: reference),
                  ),
                );

                setState(() {
                  _dialogShown = false; // Réinitialise le drapeau de dialogue
                });
              },
              child: const Text('Proceed'),
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
        ],
      ),
    );
  }
}
