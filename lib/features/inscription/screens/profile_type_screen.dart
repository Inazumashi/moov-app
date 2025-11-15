import 'package:flutter/material.dart';
// On prépare l'import pour l'écran suivant (il sera rouge pour l'instant)
import 'package:moovapp/features/inscription/screens/create_account_screen.dart';

class ProfileTypeScreen extends StatelessWidget {
  // On reçoit le nom de l'université de l'écran précédent
  final String universityName;

  const ProfileTypeScreen({
    super.key,
    required this.universityName,
  });

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
              'Votre profil',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Sélectionnez votre type de profil',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // On utilise un helper pour ne pas répéter le code
            _buildProfileCard(
              context: context,
              icon: Icons.school_outlined,
              title: 'Étudiant',
              subtitle: 'Je suis étudiant(e) dans cette université',
              color: Colors.blue.shade700,
              onTap: () {
                _navigateToNextScreen(context, 'Étudiant');
              },
            ),
            _buildProfileCard(
              context: context,
              icon: Icons.work_outline,
              title: 'Personnel administratif',
              subtitle: 'Je fais partie du personnel administratif',
              color: Colors.green.shade700,
              onTap: () {
                _navigateToNextScreen(context, 'Personnel administratif');
              },
            ),
            _buildProfileCard(
              context: context,
              icon: Icons.people_outline,
              title: 'Enseignant',
              subtitle: 'Je suis enseignant(e) ou chercheur(se)',
              color: Colors.purple.shade700,
              onTap: () {
                _navigateToNextScreen(context, 'Enseignant');
              },
            ),
            const Spacer(), // Pousse la boîte jaune en bas
            
            // La boîte d'information en bas
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow.shade700),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cette information permet de créer des sous-communautés sécurisées',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Marge en bas
          ],
        ),
      ),
    );
  }

  // Fonction pour naviguer vers l'écran suivant
  void _navigateToNextScreen(BuildContext context, String profileType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountScreen(
          universityName: universityName,
          profileType: profileType,
        ),
      ),
    );
  }

  // Widget pour chaque carte de profil
  Widget _buildProfileCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ),
    );
  }
}
