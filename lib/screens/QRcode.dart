import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: QRScannerScreen()));
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrResult;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  // Fonction pour demander l'autorisation de la caméra
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        print('Accès à la caméra autorisé.');
      } else {
        print('Accès à la caméra refusé.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de la caméra refusée')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                _buildQrView(context),
                Center(
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (qrResult != null)
                  Text('Résultat du scan : $qrResult')
                else
                  const Text('Scannez un QR code'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await requestCameraPermission();
                    controller?.resumeCamera();
                  },
                  child: const Text('Valider'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher la vue de la caméra
  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 250, // Taille de l'encadrage au milieu
      ),
      onPermissionSet: (ctrl, p) {
        if (!p) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Accès à la caméra refusé')),
          );
        }
      },
    );
  }

  // Fonction appelée lorsque le QR code est scanné
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrResult = scanData.code; // Résultat du scan
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
