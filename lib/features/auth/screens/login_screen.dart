import 'package:flutter/material.dart';
import 'package:moovapp/features/auth/widgets/auth_textfield.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/utils/email_utils.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* -------------------------------------------------------------------------- */
  /*                           VALIDATION EMAIL UNIV                            */
  /* -------------------------------------------------------------------------- */

  /* -------------------------------------------------------------------------- */
  /*                               SNACKBAR UTILS                               */
  /* -------------------------------------------------------------------------- */

  void _showError(String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: colors.error),
      );
  }

  void _showSuccess(String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: colors.secondary),
      );
  }

  void _showInfo(String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: colors.primary),
      );
  }

  /* -------------------------------------------------------------------------- */
  /*                                   LOGIN                                    */
  /* -------------------------------------------------------------------------- */

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    if (!isValidEmail(email)) {
      _showError('Veuillez entrer une adresse email valide');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(email, password);

      // Succès -> aller à l'écran principal
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
          (route) => false,
        );
      }
    } catch (e) {
      // Afficher l'erreur retournée par le service (ex: identifiants invalides)
      _showError(_extractErrorMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _extractErrorMessage(Object e) {
    final raw = e.toString();
    // Si le message contient un JSON, essayer d'extraire 'message'
    final jsonStart = raw.indexOf('{');
    if (jsonStart != -1) {
      try {
        final jsonString = raw.substring(jsonStart);
        final decoded = json.decode(jsonString) as Map<String, dynamic>;
        if (decoded.containsKey('message'))
          return decoded['message'].toString();
      } catch (_) {
        // ignore
      }
    }

    // Retirer le préfixe Exception: si présent
    if (raw.startsWith('Exception:'))
      return raw.replaceFirst('Exception:', '').trim();
    return raw;
  }

  /* -------------------------------------------------------------------------- */
  /*                                  UI BUILD                                  */
  /* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isButtonEnabled = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !_isLoading;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connexion',
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Bon retour sur Moov',
              style: TextStyle(
                color: colors.onPrimary.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionTitle('Email universitaire'),
              AuthTextField(
                controller: _emailController,
                hintText: 'ahmed.benali@um6p.ma',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Mot de passe'),
              AuthTextField(
                controller: _passwordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showInfo('Fonctionnalité à venir'),
                  child: Text('Mot de passe oublié ?',
                      style: TextStyle(color: colors.primary)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _handleLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.onPrimary),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.secondaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18, color: colors.secondary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Mode test activé - L\'API est en cours de développement',
                        style: TextStyle(color: colors.secondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Pas encore de compte ?",
                      style: TextStyle(color: colors.onSurface)),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RoutesConfigScreen()),
                            );
                          },
                    child: Text(
                      'Créer un compte',
                      style: TextStyle(
                          color: colors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outline.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 18, color: colors.onSurface),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Connexion sécurisée avec votre email universitaire vérifié',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
