import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isCameraActive = false;
  bool _dialogShown = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      isCameraActive ? controller!.resumeCamera() : controller!.pauseCamera();
    }
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
            child: isCameraActive
                ? _buildQRView(context)
                : const Center(
                    child:
                        Text('Appuyez sur le bouton pour activer la caméra')),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: result != null
                  ? Text('Contenu du QR Code : ${result!.code}')
                  : _buildActionButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _toggleCamera,
      child: Text(isCameraActive ? 'Arrêter le scan' : 'Scanner un QR code'),
    );
  }

  void _toggleCamera() {
    setState(() {
      if (isCameraActive) {
        controller?.pauseCamera();
      } else {
        controller?.resumeCamera();
      }
      isCameraActive = !isCameraActive;
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_dialogShown) {
        setState(() {
          result = scanData;
          _dialogShown = true;
        });
        _showQRCodeReceivedDialog();
      }
    });
  }

  void _showQRCodeReceivedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QRcode reçu'),
          content: Text('Contenu du QR Code : ${result!.code}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _dialogShown = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
