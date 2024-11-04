import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

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
    if (controller != null && isCameraActive) {
      controller!.resumeCamera();
    } else if (controller != null) {
      controller!.pauseCamera();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _scanImage,
                  child: const Text('Scanner une image'),
                ),
              ],
            ),
          ),
          if (result != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Contenu du QR Code : ${result!.code}'),
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
        // Arrête et ferme la caméra
        controller?.dispose();
        controller = null;
      } else {
        // Redémarre la caméra
        _startQRView();
      }
      isCameraActive = !isCameraActive;
    });
  }

  void _startQRView() {
    setState(() {
      // Reconstruit l'interface pour afficher la caméra
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
        _showQRCodeReceivedDialog(result?.code ?? 'QR code non valide');
      }
    });
  }

  void _scanImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        String? qrCode = await QrCodeToolsPlugin.decodeFrom(image.path);
        if (qrCode != null) {
          setState(() {
            result = Barcode(qrCode, BarcodeFormat.qrcode, []);
          });
          _showQRCodeReceivedDialog(qrCode);
        } else {
          _showErrorDialog('Aucun QR code détecté dans l\'image');
        }
      } catch (e) {
        _showErrorDialog('Erreur lors de la lecture du QR code');
      }
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
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
