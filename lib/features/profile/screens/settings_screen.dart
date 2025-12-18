import 'package:flutter/material.dart';
import 'package:moovapp/features/profile/screens/edit_profile_screen.dart';
import 'package:moovapp/features/profile/screens/change_password_screen.dart';
import 'package:moovapp/features/profile/screens/payment_methods_screen.dart';
import 'package:moovapp/features/profile/screens/language_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/theme_provider.dart';
import 'package:moovapp/core/providers/language_provider.dart';
import 'package:moovapp/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'Français';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pageTitleSettings,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, AppLocalizations.of(context)!.sectionAccount),
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline, color: colorScheme.onSurface),
                  title: Text('Modifier mot de passe',
                      style: TextStyle(color: colorScheme.onSurface)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colorScheme.onSurface),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      Icon(Icons.person_outline, color: colorScheme.onSurface),
                  title: Text(AppLocalizations.of(context)!.editProfile,
                      style: TextStyle(color: colorScheme.onSurface)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colorScheme.onSurface),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment_outlined,
                      color: colorScheme.onSurface),
                  title: Text(AppLocalizations.of(context)!.paymentMethods,
                      style: TextStyle(color: colorScheme.onSurface)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colorScheme.onSurface),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ));
                  },
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, AppLocalizations.of(context)!.sectionNotifications),
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.notifications_active_outlined,
                      color: colorScheme.onSurface),
                  title: Text('Notifications Push',
                      style: TextStyle(color: colorScheme.onSurface)),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                  },
                  activeThumbColor: colorScheme.primary,
                ),
                SwitchListTile(
                  secondary:
                      Icon(Icons.email_outlined, color: colorScheme.onSurface),
                  title: Text('Notifications par e-mail',
                      style: TextStyle(color: colorScheme.onSurface)),
                  subtitle: Text(
                    'Promotions, actualités, etc.',
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                  },
                  activeThumbColor: colorScheme.primary,
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, AppLocalizations.of(context)!.sectionAppearance),
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language_outlined,
                      color: colorScheme.onSurface),
                  title: Text(AppLocalizations.of(context)!.pageTitleLanguage,
                      style: TextStyle(color: colorScheme.onSurface)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getLanguageName(languageProvider.locale.languageCode),
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: colorScheme.onSurface),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LanguageSelectionScreen(),
                    ));
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.dark_mode_outlined,
                      color: colorScheme.onSurface),
                  title: Text(AppLocalizations.of(context)!.menuDarkMode,
                      style: TextStyle(color: colorScheme.onSurface)),
                  value: themeProvider.isDarkMode,
                  onChanged: themeProvider.toggleTheme,
                  activeThumbColor: colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
