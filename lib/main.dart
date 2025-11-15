import 'package:flutter/material.dart';
import 'package:moovapp/core/theme/app_theme.dart'; // 1. Importer notre nouveau thème
import 'package:moovapp/features/auth/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moov',
      // 2. Appliquer notre thème
      theme: AppTheme.lightTheme, 
      
      // On enlève le bandeau "debug" en haut à droite
      debugShowCheckedModeBanner: false, 
      
      // L'écran de démarrage est toujours le même
      home: const WelcomeScreen(),
    );
  }
}

