import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_ap3/screens/lists.dart'
    hide Product; // Cacher Product
import 'package:flutter_application_ap3/screens/Product.dart'
    as productModel; // Utiliser un alias pour Product

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  List<productModel.Product> products = []; // Liste pour stocker les produits
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductsFromFile(); // Charger les produits au démarrage
  }

  @override
  void dispose() {
    referenceController.dispose();
    designationController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  // Modification de la méthode pour retourner le chemin du fichier dans le dossier json
  Future<String> _getLocalFilePath() async {
    final directory = Directory('${Directory.current.path}/json');
    if (!await directory.exists()) {
      await directory.create(recursive: true); // Créer le dossier si nécessaire
    }
    return '${directory.path}/products.json';
  }

  Future<void> _saveProductsToFile() async {
    final filePath = await _getLocalFilePath();
    final jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  Future<List<productModel.Product>> _loadProductsFromFile() async {
    try {
      final filePath = await _getLocalFilePath();
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // Retourner la liste des produits chargés
      return jsonData
          .map((json) => productModel.Product.fromJson(json))
          .toList();
    } catch (e) {
      // Gérer les erreurs (fichier introuvable, etc.)
      print('Erreur lors du chargement des produits: $e');
      return []; // Retourner une liste vide en cas d'erreur
    }
  }

  void _addProduct() {
    final String reference = referenceController.text;
    final String designation = designationController.text;
    final int? quantity = int.tryParse(quantityController.text);

    if (reference.isNotEmpty && designation.isNotEmpty && quantity != null) {
      setState(() {
        products.add(productModel.Product(
            reference: reference,
            designation: designation,
            quantity: quantity)); // Ajouter le produit
      });

      _saveProductsToFile(); // Enregistrer les produits après ajout

      // Réinitialiser les champs après l'ajout
      referenceController.clear();
      designationController.clear();
      quantityController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit ajouté : $designation')),
      );
    } else {
      // Afficher un message d'erreur si les champs sont invalides
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Veuillez remplir tous les champs correctement.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL4SPORT - Livraison'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
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
              _buildInputField('Désignation :', designationController),
              const SizedBox(height: 10),
              _buildInputField('Quantité :', quantityController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _addProduct, // Appel de la méthode pour ajouter un produit
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
                      title: Text(products[index].designation),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              child: Image.asset('assets/paysage.jpg'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProductListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
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
