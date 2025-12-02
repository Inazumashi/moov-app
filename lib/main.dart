// File: lib/main.dart
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:moovapp/core/theme/app_theme.dart';
import 'package:moovapp/core/navigateur/app_router.dart'; // ✅ AJOUT
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
=======
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
  Locale locale = const Locale('fr');

  Locale get locale => locale;

  void setLocale(Locale locale) {
    if (!['fr', 'en', 'ar'].contains(locale.languageCode)) return;
    locale = locale;
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
>>>>>>> 7280f87d548931f0299a52342393de5087fd56ae
}

class MyApp extends StatelessWidget {
  // ... (Reste du code inchangé)
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: MaterialApp(
        title: 'Moov',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        
        // ✅ CORRECTION : Utilisation du routeur personnalisé
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.welcome,
        
        // ❌ SUPPRIMEZ cette ligne : home: const WelcomeScreen(),
      ),
    );
  }
}
=======
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
<<<<<<< HEAD
}
>>>>>>> 7280f87d548931f0299a52342393de5087fd56ae
=======
}
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9
