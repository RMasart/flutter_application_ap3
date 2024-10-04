import 'package:flutter/material.dart';
import 'package:flutter_application_ap3/screens/lists.dart';

class AuthService {
  bool isLoggedIn = false;

  void verifyCredentials(String username, String password) {
    if (username == 'toto' && password == '1234') {
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
    }
  }
}

//test
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Text(
                  'LOGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'All4Sport',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Name :'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Password :'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String username = _idController.text;
                  String password = _passwordController.text;

                  // Vérifie les identifiants
                  _authService.verifyCredentials(username, password);

                  if (_authService.isLoggedIn) {
                    // Connexion réussie, redirige vers la page ProductListScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductListScreen(),
                      ),
                    );
                  } else {
                    // Affiche un message d'erreur si les identifiants sont incorrects
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Identifiant ou mot de passe incorrect'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Confirm'),
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[400],
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: Image.asset('assets/QR.png'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
