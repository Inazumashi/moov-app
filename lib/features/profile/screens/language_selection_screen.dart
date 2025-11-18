import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});
  
  // Liste des langues supportées (basé sur votre demande)
  final List<Map<String, String>> languages = const [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية (Arabe)'},
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Le code ici devrait lire la langue actuelle du système pour cocher l'élément
    const String currentLangCode = 'fr'; 

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Langue'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: List.generate(languages.length, (index) {
            final lang = languages[index];
            final bool isSelected = lang['code'] == currentLangCode;
            
            return Column(
              children: [
                ListTile(
                  title: Text(lang['name']!),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    // TODO: Implémenter la logique de changement de langue (i18n)
                    // Cela nécessite une configuration dans pubspec.yaml
                    // Navigator.of(context).pop();
                  },
                ),
                if (index < languages.length - 1)
                  const Divider(height: 1, indent: 16),
              ],
            );
          }),
        ),
      ),
    );
  }
}