import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ForkScoreApp()));
}

class ForkScoreApp extends StatelessWidget {
  const ForkScoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForkScore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ForkScore'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'ForkScore',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Avaliações gastronômicas confiáveis',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // TODO: Navegue para login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login implementado em breve')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Text('Entrar'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navegue para signup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cadastro implementado em breve')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
