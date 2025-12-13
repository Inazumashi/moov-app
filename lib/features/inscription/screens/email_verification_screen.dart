import 'package:flutter/material.dart';
import 'package:moovapp/core/service/auth_service.dart';
import 'package:moovapp/features/main_navigation/main_navigation_shell.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyEmail() async {
    final code = _codeControllers.map((c) => c.text).join();
    
    if (code.length != 6) {
      _showError('Veuillez entrer le code complet à 6 chiffres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Vérification du code pour ${widget.email}...');
      
      // ✅ APPEL RÉEL AU BACKEND
      final response = await _authService.verifyEmailCode(widget.email, code);
      
      if (response['success'] == true) {
        print('✅ Email vérifié avec succès!');
        
        _showSuccess('Email vérifié avec succès !');
        
        // Navigation vers l'app principale
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationShell(),
          ),
          (route) => false,
        );
      } else {
        _showError('Code incorrect. Veuillez réessayer.');
        // Vider le dernier champ pour faciliter la nouvelle saisie
        _codeControllers[5].clear();
        _focusNodes[5].requestFocus();
      }
    } catch (e) {
      print('❌ Erreur vérification: $e');
      
      String errorMessage = 'Erreur de vérification';
      if (e.toString().contains('Code invalide') || e.toString().contains('expiré')) {
        errorMessage = 'Code invalide ou expiré';
      } else if (e.toString().contains('timeout') || e.toString().contains('connexion')) {
        errorMessage = 'Problème de connexion. Vérifiez votre internet.';
      }
      
      _showError('$errorMessage. Veuillez réessayer.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      print('🔄 Renvoi du code à ${widget.email}...');
      
      // ✅ APPEL RÉEL AU BACKEND
      final response = await _authService.resendVerificationCode(widget.email);
      
      if (response['success'] == true) {
        _showSuccess('Nouveau code envoyé à ${widget.email}');
        
        // Vider les champs
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        
        // Afficher le code en mode développement
        if (response['debug_code'] != null) {
          print('🔍 Code de débogage (DEV ONLY): ${response['debug_code']}');
          _showInfo('Code DEV: ${response['debug_code']}');
        }
      } else {
        _showError('Erreur lors de l\'envoi du nouveau code');
      }
    } catch (e) {
      print('❌ Erreur renvoi code: $e');
      _showError('Impossible d\'envoyer un nouveau code');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Vérifier si tous les champs sont remplis
    final allFilled = _codeControllers.every((controller) => controller.text.isNotEmpty);
    if (allFilled) {
      _verifyEmail();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vérification de l\'email',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Sécurisez votre compte',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.outline.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_outlined, color: primaryColor, size: 40),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Message principal
                    Text(
                      'Vérifiez votre email universitaire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Nous avons envoyé un code à 6 chiffres à :',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.email_outlined, color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.email,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Champ de code
                    _buildCodeInput(),
                    const SizedBox(height: 24),
                    
                    // Bouton "Vérifier"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Vérifier l\'email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bouton "Renvoyer le code"
                    Center(
                      child: TextButton(
                        onPressed: (_isLoading || _isResending) ? null : _resendCode,
                        child: _isResending
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Renvoyer le code',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    Divider(color: colors.outline.withOpacity(0.3)),
                    const SizedBox(height: 8),
                    
                    // Message d'aide
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: colors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Le code expire après 10 minutes. Vérifiez aussi vos spams.',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Indicateurs de progression
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(false, primaryColor),
                const SizedBox(width: 8),
                _buildPageIndicator(false, primaryColor),
                const SizedBox(width: 8),
                _buildPageIndicator(false, primaryColor),
                const SizedBox(width: 8),
                _buildPageIndicator(true, primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrez le code de vérification',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 58,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => _onCodeChanged(value, index),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive, Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Theme.of(context).colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}