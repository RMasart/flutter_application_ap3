import 'package:flutter/material.dart';
import 'package:flutter_application_ap3/screens/HamburgerApp.dart';
import 'screens/HamburgerApp.dart';

void main() => runApp(const HamburgerApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALL4SPORT - Liste des produits',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = [
    Product(
        reference: 'A123', designation: 'Chaussures de course', quantity: 150),
    Product(reference: 'B456', designation: 'Ballon de football', quantity: 80),
    Product(reference: 'C789', designation: 'Raquette de tennis', quantity: 50),
    Product(reference: 'D101', designation: 'Casque de vélo', quantity: 120),
    Product(reference: 'E202', designation: 'Tapis de yoga', quantity: 70),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.inventory),
              title: Text(products[index].designation),
              subtitle: Text(
                  'Référence: ${products[index].reference}, Stock: ${products[index].quantity}'),
            );
          },
        ),
      ),
    );
  }
}

class Product {
  final String reference;
  final String designation;
  final int quantity;

  Product({
    required this.reference,
    required this.designation,
    required this.quantity,
  });
}

class HamburgerApp extends StatelessWidget {
  const HamburgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HamburgerApp',
      home: HomeScreen(),
    );
  }
}
