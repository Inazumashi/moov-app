import 'package:flutter/material.dart';
// --- AJOUT DE L'IMPORT POUR LA NAVIGATION ---
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';
// ------------------------------------------

// C'est un StatefulWidget car nous devons mémoriser
// le code pays sélectionné dans le dropdown
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // On met une valeur par défaut pour le dropdown
  String _selectedCountryCode = 'MA +212';
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
              'Vérification du téléphone',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Étape 4/4 - Sécurisez votre compte',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // On met le contenu dans une carte blanche
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.phone_android_outlined, color: primaryColor, size: 32),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Numéro de téléphone',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    
                    // Champ de téléphone complexe (Dropdown + TextField)
                    _buildPhoneInput(),
                    const SizedBox(height: 24),
                    
                    // Boîte d'information
                    _buildInfoBox(primaryColor),
                    const SizedBox(height: 24),

                    // Bouton "Recevoir le code"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Logique pour envoyer le SMS
                          // TODO: Naviguer vers l'écran de saisie du code
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFa4a9d6), // Couleur grise/mauve du bouton
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Recevoir le code de vérification',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bouton "Vérifier plus tard"
                    Center(
                      child: TextButton(
                        onPressed: () {
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
                        child: Text(
                          'Vérifier plus tard',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Les 4 indicateurs en bas
            _buildPageIndicators(primaryColor),
          ],
        ),
      ),
    );
  }

  // Helper pour le champ de téléphone
  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // Le Dropdown pour le code pays
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              underline: Container(), // Enlève la ligne du dessous
              items: <String>['MA +212', 'FR +33', 'ES +34'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountryCode = newValue!;
                });
              },
            ),
          ),
          
          // Ligne de séparation verticale
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          
          // Le champ de texte pour le numéro
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '6 12 34 56 78',
                border: InputBorder.none, // On enlève la bordure du TextField
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour la boîte d'info
  Widget _buildInfoBox(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pourquoi vérifier mon numéro ?',
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoBullet('Contact direct avec les conducteurs'),
          _buildInfoBullet('Notifications SMS pour vos trajets'),
          _buildInfoBullet('Compte plus sécurisé'),
        ],
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // Helper pour les 4 indicateurs en bas
  Widget _buildPageIndicators(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageIndicator(false, primaryColor),
        _buildPageIndicator(false, primaryColor),
        _buildPageIndicator(false, primaryColor),
        _buildPageIndicator(true, primaryColor), // Le 4ème est actif
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8, // Plus long si actif
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
