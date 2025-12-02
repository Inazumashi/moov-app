import 'package:flutter/material.dart';
import 'package:moovapp/features/auth/screens/login_screen.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';
import 'package:moovapp/core/navigateur/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,

      // SafeArea évite que notre app se superpose à la barre d'heure/batterie
      body: SafeArea(
        // Padding pour ajouter des marges sur les côtés
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),

          // Column pour organiser nos widgets verticalement
          child: Column(
            children: [
              // 'Spacer' pousse le contenu vers le centre et le bas
              const Spacer(),

              // Étape 2: Le logo "Moov"
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                decoration: BoxDecoration(
                  // Couleur légèrement plus claire pour le logo
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 80, 
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 32),

              // Étape 3: Les textes
              const Text(
                'Le covoiturage entre étudiants et personnel universitaire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Partagez vos trajets en toute sécurité au sein de votre communauté universitaire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70, // Un peu transparent
                  fontSize: 16,
                ),
              ),

              // 'Spacer' pousse les boutons vers le bas
              const Spacer(),

              // Étape 4: Les boutons

              // Bouton "Commencer"
              SizedBox(
                width: double.infinity, // Prend toute la largeur
                child: ElevatedButton(
                  onPressed: () {
                    // MISE À JOUR: Naviguer vers l'écran d'inscription
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RoutesConfigScreen(),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fond blanc
                    foregroundColor: primaryColor, // Texte bleu
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Commencer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton "J'ai déjà un compte"
              SizedBox(
                width: double.infinity, // Prend toute la largeur
                child: ElevatedButton(
                  onPressed: () {
                    // MISE À JOUR: Naviguer vers l'écran de connexion
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fond blanc
                    foregroundColor: primaryColor, // Texte bleu
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "J'ai déjà un compte",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Étape 5: Les indicateurs (les petits points)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // --------- LOGO ---------
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Text(
                      'Moov',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --------- TITRE ---------
                  const Text(
                    'Le covoiturage entre étudiants et personnel universitaire',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --------- SOUS-TITRE ---------
                  const Text(
                    'Partagez vos trajets en toute sécurité au sein de votre communauté universitaire',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(),

                  // --------- BOUTON COMMENCER ---------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RoutesConfigScreen(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Commencer',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --------- BOUTON DEJA UN COMPTE ---------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "J'ai déjà un compte",
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --------- INDICATEURS (POINTS) ---------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageIndicator(isActive: true),
                      _buildPageIndicator(isActive: false),
                      _buildPageIndicator(isActive: false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------
          //               BOUTON TEST BACKEND
          // -------------------------------------------------
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.connectionTest);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Test Backend',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Indicateur (petits points)
  Widget _buildPageIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 16.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
