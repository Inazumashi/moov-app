import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller; // Pour récupérer le texte
  
  // CORRECTION: On remplace 'obscureText' par 'isPassword'
  final bool isPassword; 
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    
    // CORRECTION: Le paramètre s'appelle 'isPassword'
    this.isPassword = false, 
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // On connecte le contrôleur
      
      // CORRECTION: On utilise 'isPassword' ici
      obscureText: isPassword, 
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        // Bordure quand le champ n'est pas sélectionné
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        // Bordure quand on clique sur le champ
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
