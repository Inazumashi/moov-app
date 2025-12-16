/// Utilitaires pour la validation et le traitement des mots de passe

class PasswordValidator {
  /// Valide un mot de passe selon les critères Moov
  /// Critères:
  /// - Minimum 8 caractères
  /// - Au moins 1 chiffre (0-9)
  /// - Au moins 1 lettre majuscule (A-Z)
  /// - Au moins 1 symbole spécial
  static bool isPasswordValid(String password) {
    if (password.length < 8) return false;

    // Vérifie la présence d'un chiffre
    if (!RegExp(r'\d').hasMatch(password)) return false;

    // Vérifie la présence d'une majuscule
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Vérifie la présence d'un symbole spécial
    if (!RegExp(r'[!@#$%^&*\(\)_+\-=\[\]{};:,./<>?\\|]').hasMatch(password)) {
      return false;
    }

    return true;
  }

  /// Retourne un message d'erreur détaillé si le mot de passe n'est pas valide
  static String getPasswordError(String password) {
    if (password.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (password.length < 8) {
      return 'Le mot de passe doit contenir au minimum 8 caractères (actuellement ${password.length})';
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins 1 chiffre (0-9)';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins 1 lettre majuscule (A-Z)';
    }

    if (!RegExp(r'[!@#$%^&*\(\)_+\-=\[\]{};:,./<>?\\|]').hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins 1 symbole spécial (!@#\$%^&*)';
    }

    return '';
  }

  /// Vérifie la force du mot de passe
  /// Retourne une chaîne: "weak", "medium", ou "strong"
  static String getPasswordStrength(String password) {
    if (!isPasswordValid(password)) return 'weak';

    int score = 0;

    // Plus long = plus fort
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Mélange de caractères = plus fort
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecial =
        RegExp(r'[!@#$%^&*\(\)_+\-=\[\]{};:,./<>?\\|]').hasMatch(password);

    if (hasLower && hasUpper && hasDigit && hasSpecial) score++;

    if (score >= 2) return 'strong';
    return 'medium';
  }
}
