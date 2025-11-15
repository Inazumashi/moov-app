import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
      ),
      body: const Center(
        child: Text(
          'Écran Aide & Support',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

