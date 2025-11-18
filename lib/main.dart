import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Nécessaire pour les localisations
import 'package:provider/provider.dart'; // Nécessaire pour le Mode Sombre

// IMPORTS DE NOTRE LOGIQUE CORE
import 'package:moovapp/core/theme/app_theme.dart';
import 'package:moovapp/core/providers/theme_provider.dart';
import 'package:moovapp/features/auth/screens/welcome_screen.dart';

// IMPORTS DU CODE DE TRADUCTION GÉNÉRÉ
// NOTE: Vous devez installer le package 'flutter_gen_runner' pour que ça fonctionne
import 'package:moovapp/l10n/app_localizations.dart';


void main() {
  // 1. On démarre l'application avec le Provider pour gérer le thème
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. On "écoute" l'état du thème sombre
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Moov',
      debugShowCheckedModeBanner: false,

      // --- CONFIGURATION DU THÈME ---
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme, // Utilisera le thème sombre que vous devez définir
      themeMode: themeProvider.themeMode, // Bascule entre light/dark basé sur le Provider

      // --- CONFIGURATION DE LA TRADUCTION (i18n) ---
      // 3. Déléguer le chargement des fichiers .arb
      localizationsDelegates: const [
        AppLocalizations.delegate, // Le delegate généré par Flutter (à partir des fichiers .arb)
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 4. Définir les langues que nous supportons
      supportedLocales: const [
        Locale('en', ''), // Anglais
        Locale('fr', ''), // Français
        Locale('ar', ''), // Arabe
      ],
      
      // L'écran de démarrage
      home: const WelcomeScreen(),
    );
  }
}