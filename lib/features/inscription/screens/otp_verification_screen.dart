import 'package:flutter/material.dart';
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
    // Récupérer le code complet
    final code = _codeControllers.map((c) => c.text).join();
    
    if (code.length != 6) {
      _showError('Veuillez entrer le code complet à 6 chiffres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulation de vérification
    await Future.delayed(const Duration(seconds: 2));

    try {
      // SIMULATION : Vérification réussie
      // En production, vous appellerez votre API
      
      // Naviguer vers l'app principale
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavigationShell(),
        ),
        (route) => false,
      );

      _showSuccess('Email vérifié avec succès !');

    } catch (e) {
      _showError('Code incorrect. Veuillez réessayer.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Vérifier si tous les champs sont remplis
    final allFilled = _codeControllers.every((controller) => controller.text.isNotEmpty);
    if (allFilled) {
      _verifyEmail();
    }
  }

  void _resendCode() {
    // SIMULATION : Renvoyer le code
    _showInfo('Nouveau code envoyé à ${widget.email}');
    
    // Vider les champs
    for (var controller in _codeControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              'Étape 4/4 - Sécurisez votre compte',
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
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.email_outlined, color: primaryColor, size: 32),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Message principal
                    const Text(
                      'Vérifiez votre email universitaire',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Nous avons envoyé un code à 6 chiffres à :',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Champ de code à 6 chiffres
                    _buildCodeInput(),
                    const SizedBox(height: 24),
                    
                    // Bouton "Vérifier"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Vérifier l\'email',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bouton "Renvoyer le code"
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _resendCode,
                        child: Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Bouton "Vérifier plus tard"
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const MainNavigationShell(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Vérifier plus tard',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Indicateurs de page
            _buildPageIndicators(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Column(
      children: [
        const Text(
          'Entrez le code de vérification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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

  Widget _buildPageIndicators(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageIndicator(false, primaryColor),
        _buildPageIndicator(false, primaryColor),
        _buildPageIndicator(false, primaryColor),
        _buildPageIndicator(true, primaryColor),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}