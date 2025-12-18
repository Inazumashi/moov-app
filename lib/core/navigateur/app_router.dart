import 'package:flutter/material.dart';
import 'package:moovapp/features/auth/screens/login_screen.dart';
import 'package:moovapp/features/auth/screens/welcome_screen.dart';
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';
import 'package:moovapp/features/inscription/screens/university_select_screen.dart';
// ✅ AJOUT: Import de l'écran de test de connexion
import 'package:moovapp/features/test/screens/connection_test_screen.dart';

import 'package:moovapp/features/ride/screens/publish_ride_screen.dart'; // ✅ IMPORT

class AppRouter {
  // Noms des routes statiques
  static const String welcome = '/';
  static const String login = '/login';
  static const String onboardingRoutes = '/onboarding/routes';
  static const String onboardingUniversity = '/onboarding/university';
  static const String home = '/home';
  static const String publishRide = '/publish'; // ✅ AJOUT: Route de publication
  // ✅ AJOUT: Route de test de connexion backend
  static const String connectionTest = '/test/connection';

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
      case publishRide: // ✅ AJOUT: Case pour publication
        return MaterialPageRoute(builder: (_) => const PublishRideScreen());
      // ✅ AJOUT: Route de test de connexion
      case connectionTest:
        return MaterialPageRoute(builder: (_) => const ConnectionTestScreen());

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
