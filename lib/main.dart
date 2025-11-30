// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/theme/app_theme.dart';
import 'package:moovapp/core/navigateur/app_router.dart'; // ✅ AJOUT
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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