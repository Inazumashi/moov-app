import 'package:flutter/material.dart';
import 'package:moovapp/features/auth/screens/login_screen.dart';
import 'package:moovapp/features/auth/screens/welcome_screen.dart';
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';
import 'package:moovapp/features/inscription/screens/university_select_screen.dart';
// ... (importer d'autres écrans au besoin)

// Ce fichier pourrait gérer la navigation complexe (GoRouter, etc.)
// Pour l'instant, il peut contenir les noms de routes statiques
// pour éviter les "magic strings" (chaînes de caractères magiques).

class AppRouter {
  // Noms des routes statiques
  static const String welcome = '/';
  static const String login = '/login';
  static const String onboardingRoutes = '/onboarding/routes';
  static const String onboardingUniversity = '/onboarding/university';
  static const String home = '/home';

  // Fonction pour générer les routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case onboardingRoutes:
        return MaterialPageRoute(builder: (_) => const RoutesConfigScreen());
      case onboardingUniversity:
        // --- MODIFICATION ICI ---
        // 1. On récupère la liste envoyée via les arguments
        final args = settings.arguments as List<RouteInfo>;
        
        // 2. On injecte 'args' dans le paramètre 'routes'.
        // Note : On a retiré le mot 'const' devant UniversitySelectScreen
        return MaterialPageRoute(
          builder: (_) => UniversitySelectScreen(routes: args),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell());

      // Route par défaut en cas d'erreur
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non trouvée: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
