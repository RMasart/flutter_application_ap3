import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text("Hamburger Story"),
      ),
      drawer: Drawer(
        child: DrawerHeader(
          child: Image.asset('assets/QR.png'),
        ),
      ),
    );
  }
}
