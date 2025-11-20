import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  
  // 1. NOUVEAU : La variable pour activer la lecture seule
  final bool isReadOnly;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    // 2. NOUVEAU : On l'initialise à 'false' par défaut
    // (Comme ça, ça ne casse pas l'écran de login)
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      
      // 3. NOUVEAU : On connecte la variable au TextField
      readOnly: isReadOnly,
      
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        
        // 4. STYLE : Si c'est en lecture seule, on met un fond gris clair
        filled: true,
        fillColor: isReadOnly ? Colors.grey.shade200 : Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}