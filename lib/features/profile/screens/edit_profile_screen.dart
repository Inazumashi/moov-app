import 'package:flutter/material.dart';
import 'package:moovapp/features/auth/widgets/auth_textfield.dart';

// On utilise un StatefulWidget pour gérer les contrôleurs de texte
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Contrôleurs pour les champs
  final _fullNameController = TextEditingController(text: 'Ahmed Benali');
  final _emailController = TextEditingController(text: 'ahmed.benali@um6p.ma');
  final _phoneController = TextEditingController(text: '+212 6XX XXX XXX');

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Modifier le profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Nom Complet ---
              Text(
                'Nom complet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              AuthTextField(
                controller: _fullNameController,
                hintText: 'Ahmed Benali',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 24),

              // --- Email (non modifiable) ---
              Text(
                'Email universitaire',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              AuthTextField(
                controller: _emailController,
                hintText: 'email@universite.ma',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true, // L'email ne doit pas être modifiable
              ),
              SizedBox(height: 24),

              // --- Téléphone ---
              Text(
                'Téléphone',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              AuthTextField(
                controller: _phoneController,
                hintText: '+212 6XX XXX XXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 32),

              // --- Bouton Enregistrer ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Logique pour appeler user.controller.updateProfile
                    // et enregistrer les modifications dans le backend.
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
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