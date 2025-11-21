import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  final List<Map<String, String>> languages = const [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية (Arabe)'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    const String currentLangCode = 'fr'; // TODO: lire la langue actuelle

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
            final bool isSelected = lang['code'] == currentLangCode;

            return Column(
              children: [
                ListTile(
                  title: Text(
                    lang['name']!,
                    style: TextStyle(color: colors.onBackground),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: colors.primary)
                      : null,
                  onTap: () {
                    // TODO: Logique de changement de langue
                    // Navigator.of(context).pop();
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
