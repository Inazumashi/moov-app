import 'package:flutter/material.dart';
import 'package:moovapp/features/profile/screens/change_password_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Sécurité',
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),

      body: ListView(
        children: [
          _buildSectionTitle('Gestion du mot de passe'),
          Container(
            color: colors.surface,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline, color: colors.onSurface),
                  title: Text(
                    'Changer le mot de passe',
                    style: TextStyle(color: colors.onSurface),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: colors.onSurface),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          _buildSectionTitle('Authentification à deux facteurs'),
          Container(
            color: colors.surface,
            child: Column(
              children: [
                SwitchListTile(
                  secondary:
                      Icon(Icons.shield_outlined, color: colors.onSurface),
                  title: Text(
                    'Authentification à deux facteurs',
                    style: TextStyle(color: colors.onSurface),
                  ),
                  subtitle: Text(
                    'Utilisez un code SMS pour plus de sécurité.',
                    style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                  ),
                  value: _twoFactorAuth,
                  onChanged: (bool value) {
                    setState(() {
                      _twoFactorAuth = value;
                    });
                  },
                  activeColor: colors.primary,
                  activeTrackColor: colors.primary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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
