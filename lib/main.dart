import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:moovapp/core/theme/app_theme.dart';
import 'package:moovapp/core/providers/theme_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/features/auth/screens/welcome_screen.dart';
import 'package:moovapp/l10n/app_localizations.dart';
import 'package:moovapp/features/favorites/providers/favorite_rides_provider.dart';

// --- LanguageProvider ---
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['fr', 'en', 'ar'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}

void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()), 
        ChangeNotifierProvider(create: (_) => FavoriteRidesProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // ... (Reste du code inchangé)
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Moov',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // --- LOCALISATIONS ---
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      locale: languageProvider.locale,
      home: const WelcomeScreen(),
    );
  }
}