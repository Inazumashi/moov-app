import 'package:flutter/material.dart';
import 'package:moovapp/features/auth/widgets/auth_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              AuthTextField(
                controller: _fullNameController,
                hintText: 'Ahmed Benali',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 24),

              // Email (non modifiable)
              Text(
                'Email universitaire',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              AuthTextField(
                controller: _emailController,
                hintText: 'email@universite.ma',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true,
              ),

              const SizedBox(height: 24),

              // Téléphone
              Text(
                'Téléphone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.onSurface,
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
                  onPressed: () {
                    // TODO: updateProfile
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: const Text(
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
