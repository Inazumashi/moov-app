import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import
import 'package:moovapp/core/service/auth_service.dart';   // ✅ Import
import 'package:moovapp/features/auth/widgets/auth_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // On initialise vide, on remplira dans initState
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthService _authService = AuthService(); // Instance du service
  bool _isLoading = false; // Pour le bouton de chargement

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Chargement des données au lancement
  }

  // 1. Charger les données actuelles
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String fName = prefs.getString('first_name') ?? "";
      String lName = prefs.getString('last_name') ?? "";
      _fullNameController.text = "$fName $lName".trim();
      
      _emailController.text = prefs.getString('email') ?? "";
      _phoneController.text = prefs.getString('phone') ?? "";
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 2. Fonction pour sauvegarder
  void _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      await _authService.updateProfile(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // On revient en arrière (true indique un changement)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : Impossible de mettre à jour le profil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Modifier le profil',
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom Complet
              Text(
                'Nom complet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              AuthTextField(
                controller: _fullNameController,
                hintText: 'Nom Prénom',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 24),

              // Email (non modifiable)
              Text(
                'Email universitaire',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              AuthTextField(
                controller: _emailController,
                hintText: 'email@universite.ma',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true, // Bloqué car identifiant unique souvent
              ),

              const SizedBox(height: 24),

              // Téléphone
              Text(
                'Téléphone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              AuthTextField(
                controller: _phoneController,
                hintText: '+212 6XX XXX XXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges, // Désactivé si chargement
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}