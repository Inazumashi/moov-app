import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/language_provider.dart'; // <-- à créer

class LanguageSelectionScreen extends StatelessWidget {
  LanguageSelectionScreen({super.key});

  final List<Map<String, String>> languages = const [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية (Arabe)'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // On récupère le LanguageProvider pour connaître la langue actuelle
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Langue',
          style: TextStyle(color: colors.onPrimary),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: List.generate(languages.length, (index) {
            final lang = languages[index];
            final bool isSelected = lang['code'] == currentLocale.languageCode;

            return Column(
              children: [
                ListTile(
                  title: Text(
                    lang['name']!,
                    style: TextStyle(color: colors.onBackground),
                  ),
                  trailing:
                      isSelected ? Icon(Icons.check, color: colors.primary) : null,
                  onTap: () {
                    // Mise à jour de la langue via le provider
                    languageProvider.setLocale(Locale(lang['code']!));
                  },
                ),
                if (index < languages.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colors.outline.withOpacity(0.3),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
