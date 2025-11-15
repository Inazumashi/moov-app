import 'package:flutter/material.dart';
// CORRECTION 1: Ajout de l'import manquant
import 'package:moovapp/features/inscription/screens/profile_type_screen.dart';

// Pour cet écran, une liste statique est suffisante
// Un StatelessWidget est parfait
class UniversitySelectScreen extends StatelessWidget {
  const UniversitySelectScreen({super.key});

  // On crée une classe simple pour modéliser nos données
  // (Dans une vraie app, cela viendrait d'une base de données)
  static const List<Map<String, String>> universities = [
    {
      'name': 'Université Mohammed VI Polytechnique',
      'count': '3,200+ étudiants',
    },
    {
      'name': 'Université Cadi Ayyad',
      'count': '45,000+ étudiants',
    },
    {
      'name': 'Université Internationale de Rabat',
      'count': '5,000+ étudiants',
    },
    {
      'name': 'Université Hassan II de Casablanca',
      'count': '80,000+ étudiants',
    },
    {
      'name': 'Université Mohammed V',
      'count': '70,000+ étudiants',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
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
              'Sélectionnez votre université',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Rejoignez votre communauté universitaire',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          // La liste va prendre tout l'espace disponible
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: universities.length,
              itemBuilder: (context, index) {
                final uni = universities[index];
                return _buildUniversityCard(
                  context: context,
                  icon: Icons.school_outlined,
                  title: uni['name']!,
                  subtitle: uni['count']!,
                  primaryColor: primaryColor,
                  onTap: () {
                    // CORRECTION 2: On passe le nom de l'université
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfileTypeScreen(
                        universityName: uni['name']!,
                      ),
                    ));
                  },
                );
              },
            ),
          ),

          // La boîte d'information en bas
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous ne verrez que les trajets de votre communauté pour plus de sécurité',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour chaque carte d'université
  Widget _buildUniversityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
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
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

