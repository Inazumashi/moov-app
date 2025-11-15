import 'package:flutter/material.dart';
// On importe notre widget personnalisé
import 'package:moovapp/features/auth/widgets/auth_textfield.dart';

// --- AJOUT DES IMPORTS POUR LA NAVIGATION ---
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';
// ------------------------------------------

// On utilise un StatefulWidget pour pouvoir utiliser des TextEditingController
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // On crée les contrôleurs pour récupérer le texte
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Il est très important de "disposer" les contrôleurs
    // pour éviter les fuites de mémoire
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connexion',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Bon retour sur Moov',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 1. Champ Email (on utilise notre widget)
              _buildSectionTitle('Email universitaire'),
              AuthTextField(
                controller: _emailController,
                hintText: 'ahmed.benali@um6p.ma',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // 2. Champ Mot de passe (on utilise notre widget)
              _buildSectionTitle('Mot de passe'),
              AuthTextField(
                controller: _passwordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 8),

              // Bouton "Mot de passe oublié ?"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Gérer le mot de passe oublié
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton "Se connecter"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Gérer la VRAIE logique de connexion (vérifier email/pass)
                    
                    // --- MISE À JOUR DE LA NAVIGATION ---
                    // On navigue vers l'écran principal et on supprime
                    // toutes les routes précédentes (on ne peut pas revenir en arrière)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationShell(),
                      ),
                      (route) => false, // Supprime tout l'historique de navigation
                    );
                    // ------------------------------------
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lien "Créer un compte"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pas encore de compte ?"),
                  TextButton(
                    onPressed: () {
                      // --- MISE À JOUR DE LA NAVIGATION ---
                      // Naviguer vers l'écran d'inscription (étape 1)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RoutesConfigScreen(),
                        ),
                      );
                      // ------------------------------------
                    },
                    child: Text(
                      'Créer un compte',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // La petite boîte d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 18, color: Colors.black54),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Connexion sécurisée avec votre email universitaire vérifié',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Petite fonction pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

