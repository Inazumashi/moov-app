import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:moovapp/core/theme/app_theme.dart';
import 'package:moovapp/core/providers/theme_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/features/auth/screens/welcome_screen.dart';


import 'package:moovapp/l10n/app_localizations.dart';

void main() {
  runApp(
    // On utilise MultiProvider pour injecter nos providers (Thème et Auth) dans l'app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le ThemeProvider pour changer le thème dynamiquement
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Moov',
      debugShowCheckedModeBanner: false,

      // --- CONFIGURATION DU THÈME ---
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // --- CONFIGURATION DE LA TRADUCTION ---
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'), // Français
        Locale('en'), // Anglais
        Locale('ar'), // Arabe
      ],
      // Langue par défaut
      locale: const Locale('fr'), 

      // L'écran de démarrage
      home: const WelcomeScreen(),
    );
  }
}