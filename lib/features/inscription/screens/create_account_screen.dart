import 'package:flutter/material.dart';
// On importe notre widget réutilisable
import 'package:moovapp/features/auth/widgets/auth_textfield.dart';
// --- REMPLACEZ CET IMPORT ---
import 'package:moovapp/features/inscription/screens/email_verification_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final String universityName;
  final String profileType;

  const CreateAccountScreen({
    super.key,
    required this.universityName,
    required this.profileType,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Un contrôleur pour chaque champ
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // On n'oublie pas de les "dispose" pour libérer la mémoire
  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer un compte',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Rejoignez Moov',
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
              const SizedBox(height: 8),
              
              _buildSectionTitle('Nom complet'),
              AuthTextField(
                controller: _nomController,
                hintText: 'Ahmed Benali',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Email universitaire'),
              AuthTextField(
                controller: _emailController,
                hintText: 'ahmed.benali@um6p.ma',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const Text(
                'Utilisez votre email universitaire officiel',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Téléphone (optionnel)'),
              AuthTextField(
                controller: _telephoneController,
                hintText: '+212 6XX XXX XXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Mot de passe'),
              AuthTextField(
                controller: _passwordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Confirmer le mot de passe'),
              AuthTextField(
                controller: _confirmPasswordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              
              // Boîte d'information sur la vérification
              _buildInfoBox(),
              const SizedBox(height: 24),

              // Bouton "Créer mon compte"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validation des champs
                    if (_nomController.text.isEmpty || 
                        _emailController.text.isEmpty || 
                        _passwordController.text.isEmpty) {
                      _showError('Veuillez remplir tous les champs obligatoires');
                      return;
                    }

                    if (_passwordController.text != _confirmPasswordController.text) {
                      _showError('Les mots de passe ne correspondent pas');
                      return;
                    }

                    // --- NAVIGATION VERS VÉRIFICATION EMAIL ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailVerificationScreen(
                          email: _emailController.text,
                        ),
                      ),
                    );
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
                    'Créer mon compte',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Texte des conditions d'utilisation
              const Text(
                "En créant un compte, vous acceptez nos conditions d'utilisation et notre politique de confidentialité",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // Helper pour la boîte d'information
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.email_outlined, color: Colors.blue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Un code de vérification sera envoyé à votre email universitaire',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}