import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'Product.dart' as productModel;

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<productModel.Product> products = [];
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController entrepriseController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    final directory = Directory('${Directory.current.path}/json');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

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
          products = jsonData
              .map((json) => productModel.Product.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }

  void _addProduct() {
    final String reference = referenceController.text; // Référence
    final String entreprise = entrepriseController.text;
    final int? quantity = int.tryParse(quantityController.text); // Quantité

    if (reference.isNotEmpty && entreprise.isNotEmpty && quantity != null) {
      setState(() {
        // Créez un nouveau produit avec la référence, l'entreprise et la quantité
        products.add(productModel.Product(
          reference: reference,
          entreprise: entreprise,
          quantity: quantity,
        ));
      });

      _saveProductsToFile();

      referenceController.clear();
      entrepriseController.clear();
      quantityController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit ajouté : $entreprise')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs correctement.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL4SPORT - Livraison'),
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
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[400],
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(products[index].entreprise),
                      subtitle: Text(
                          'Référence: ${products[index].reference}, Quantité: ${products[index].quantity}'),
                    );
                  },
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
