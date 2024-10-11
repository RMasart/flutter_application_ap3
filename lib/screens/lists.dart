import 'package:flutter/material.dart';
import 'package:flutter_application_ap3/screens/delivery.dart'; // Importer la page de livraison

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Créez une liste de produits
  final List<Product> products = [
    Product(reference: 'A123', entreprise: 'Nike', quantity: 150),
    Product(reference: 'B456', entreprise: 'Adidas', quantity: 80),
    Product(reference: 'C789', entreprise: 'Wilson', quantity: 50),
    Product(reference: 'D101', entreprise: 'Bell', quantity: 120),
    Product(reference: 'E202', entreprise: 'Lululemon', quantity: 70),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL4SPORT - Liste des produits'),
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
              leading: Image.asset('assets/QR.png', width: 24, height: 24),
              title: const Text('QRCode'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  Image.asset('assets/delivery.jpg', width: 24, height: 24),
              title: const Text('Delivery'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeliveryScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.inventory),
              title: Text(products[index].entreprise), // Entreprise
              subtitle: Text(
                  'Référence: ${products[index].reference}, Stock: ${products[index].quantity}'), // Numéro
            );
          },
        ),
      ),
    );
  }
}

class Product {
  final String reference; // Numéro
  final String entreprise; // Entreprise
  final int quantity; // Quantité

  Product({
    required this.reference,
    required this.entreprise,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'entreprise': entreprise,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      reference: json['reference'],
      entreprise: json['entreprise'],
      quantity: json['quantity'],
    );
  }
}
