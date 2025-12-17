import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/language_provider.dart'; // <-- à créer
import 'package:moovapp/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  List<Map<String, String>> _getLanguages(BuildContext context) => [
    {'code': 'fr', 'name': AppLocalizations.of(context)!.placeholderFrench},
    {'code': 'en', 'name': AppLocalizations.of(context)!.placeholderEnglish},
    {'code': 'ar', 'name': AppLocalizations.of(context)!.placeholderArabic},
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
          AppLocalizations.of(context)!.pageTitleLanguage,
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
          children: List.generate(_getLanguages(context).length, (index) {
            final lang = _getLanguages(context)[index];
            final bool isSelected = lang['code'] == currentLocale.languageCode;

            return Column(
              children: [
                ListTile(
                  title: Text(
                    lang['name']!,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: colors.primary)
                      : null,
                  onTap: () {
                    // Mise à jour de la langue via le provider
                    languageProvider.setLocale(Locale(lang['code']!));
                    // Retour à l'écran précédent
                    Navigator.of(context).pop();
                  },
                ),
                if (index < _getLanguages(context).length - 1)
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