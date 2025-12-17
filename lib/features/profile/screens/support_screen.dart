import 'package:flutter/material.dart';
// 1. IMPORTS
import 'package:moovapp/features/profile/screens/faq_screen.dart';
import 'package:moovapp/features/profile/screens/contact_us_screen.dart';
import 'package:moovapp/features/profile/screens/terms_of_service_screen.dart';
import 'package:moovapp/features/profile/screens/privacy_policy_screen.dart';
import 'package:moovapp/l10n/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.helpSupport,
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
      body: ListView(
        children: <Widget>[
          // SECTION AIDE
          _buildSectionTitle(context, AppLocalizations.of(context)!.help),
          Container(
            color: colors.surface,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.quiz_outlined, color: colors.onSurface),
                  title: Text(
                    AppLocalizations.of(context)!.pageTitleFaq,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colors.onSurface),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FaqScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.email_outlined, color: colors.onSurface),
                  title: Text(
                    AppLocalizations.of(context)!.pageTitleContact,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colors.onSurface),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ContactUsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // SECTION LEGAL
          _buildSectionTitle(context, AppLocalizations.of(context)!.sectionLegal),
          Container(
            color: colors.surface,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.gavel_outlined, color: colors.onSurface),
                  title: Text(
                    AppLocalizations.of(context)!.pageTitleTerms,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colors.onSurface),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.privacy_tip_outlined, color: colors.onSurface),
                  title: Text(
                    AppLocalizations.of(context)!.pageTitlePrivacy,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colors.onSurface),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TITRE DE SECTION AVEC COULEURS DU THÈME
  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}