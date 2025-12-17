import 'package:flutter/material.dart';
import 'package:moovapp/features/inscription/screens/university_select_screen.dart';
import 'package:moovapp/l10n/app_localizations.dart';


class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.myCommunities,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Carte de la communauté principale
          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      child: Icon(Icons.school, color: colorScheme.primary),
                    ),
                    title: Text(
                      'UM6P - Étudiants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Communauté principale',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  Divider(
                    height: 24,
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                  Row(
                    children: [
                      Icon(Icons.people,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '3,200+ membres',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton "Rejoindre une communauté"
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UniversitySelectScreen(
                    routes: [],
                  ),
                     
                ),
              );
            },
            icon: Icon(
              Icons.add,
              color: colorScheme.onSurface,
            ),
            label: Text(
              'Rejoindre une autre communauté',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
