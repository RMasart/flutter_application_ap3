import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'product.dart' as productModel;

class DeliveryScreen extends StatefulWidget {
  final String? initialReference;

  const DeliveryScreen({Key? key, this.initialReference}) : super(key: key);

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<productModel.Product> products = [];
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController entrepriseController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  bool isOnline = false; // Par défaut hors ligne

  @override
  void initState() {
    super.initState();
    referenceController.text = widget.initialReference ?? '';
    _loadProductsFromFile();
  }

  @override
  void dispose() {
    referenceController.dispose();
    entrepriseController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/products.json';
  }

  Future<void> _saveProductsToFile() async {
    final filePath = await _getLocalFilePath();
    final jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  Future<void> _loadProductsFromFile() async {
    try {
      final filePath = await _getLocalFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(jsonString);

        setState(() {
          products = jsonData.map((json) {
            return productModel.Product(
              reference: json['reference'],
              entreprise: json['entreprise'],
              quantity: json['quantity'],
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }

  void _addProduct() {
    final String reference = referenceController.text;
    final String entreprise = entrepriseController.text;
    final int? quantity = int.tryParse(quantityController.text);

    if (reference.isNotEmpty && entreprise.isNotEmpty && quantity != null) {
      setState(() {
        products.add(productModel.Product(
          reference: reference,
          entreprise: entreprise,
          quantity: quantity,
        ));
      });

      _saveProductsToFile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit ajouté : $entreprise')),
      );

      referenceController.clear();
      entrepriseController.clear();
      quantityController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs correctement.'),
        ),
      );
    }
  }

  Future<void> _synchronizeData() async {
    try {
      for (var product in products) {
        print('Synchronisation du produit : ${product.reference}');
        // Simulez un appel API ici
        await Future.delayed(
            const Duration(seconds: 1)); // Simulation délai réseau
      }

      setState(() {
        products.clear();
      });
      await _saveProductsToFile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronisation réussie.')),
      );
    } catch (e) {
      print('Erreur lors de la synchronisation : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de synchronisation.')),
      );
    }
  }

  void _toggleOnlineStatus() {
    setState(() {
      isOnline = !isOnline; // Inverse l'état en ligne / hors ligne
    });
  }

  void _sendToDatabase() async {
    if (isOnline) {
      await _synchronizeData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous êtes hors ligne.')),
      );
    }
  }

  String _getJsonString() {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(products.map((p) => p.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL4SPORT - Livraison'),
        actions: [
          GestureDetector(
            onTap: _toggleOnlineStatus, // Permet de cliquer sur le cercle
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.circle,
                color: isOnline ? Colors.green : Colors.red,
                size: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/delivery.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField('Référence :', referenceController),
              const SizedBox(height: 10),
              _buildInputField('Entreprise :', entrepriseController),
              const SizedBox(height: 10),
              _buildInputField('Quantité :', quantityController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Confirmer'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isOnline ? _sendToDatabase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline ? Colors.blue : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Envoyer vers la BDD'),
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[400],
                child: SingleChildScrollView(
                  child: Text(
                    _getJsonString(),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInputField(
      String label, TextEditingController controller) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              fillColor: Colors.grey[300],
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
