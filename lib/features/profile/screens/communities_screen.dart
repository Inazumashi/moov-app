import 'package:flutter/material.dart';
// 1. ON AJOUTE L'IMPORT VERS L'ÉCRAN DE SÉLECTION
import 'package:moovapp/features/inscription/screens/university_select_screen.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Mes communautés',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Carte pour la communauté principale (l'université)
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.school,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'UM6P - Étudiants', // TODO: Rendre dynamique
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Communauté principale'),
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      // TODO: Rendre dynamique
                      Text('3,200+ membres'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Bouton pour ajouter d'autres communautés
          OutlinedButton.icon(
            onPressed: () {
              // 2. ON AJOUTE LA NAVIGATION ICI
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UniversitySelectScreen(),
              ));
            },
            icon: Icon(Icons.add),
            label: Text('Rejoindre une autre communauté'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}