import 'package:flutter/material.dart';
import 'package:flutter_application_ap3/screens/lists.dart';
import 'package:flutter_application_ap3/screens/ProductListScreen.dart';
import 'package:flutter_application_ap3/screens/login.dart'; // Importation de la page de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALL4SPORT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}