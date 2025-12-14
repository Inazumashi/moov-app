bool isAcademicEmail(String email) {
  const allowedDomains = <String>[
    'um6p.ma',
    'uir.ma',
    'uic.ma',
    'aui.ac.ma',
    'alakhawayn.ma',
    // Ajoute d'autres domaines ici :
    'ensa.ac.ma',
    'encg.ma',
    'fst.ac.ma',
    'uca.ma',
    'uh2c.ac.ma',
    'usmba.ac.ma',
    // ...
  ];

  final domain =
      email.split('@').length == 2 ? email.split('@').last.toLowerCase() : '';
  return domain.isNotEmpty && allowedDomains.contains(domain);
}

// Validation simple de la syntaxe d'un email (utilisée pour les formulaires de connexion)
bool isValidEmail(String email) {
  if (email.isEmpty) return false;
  // Autorise sous-domaines (ex: user@dept.univ.ac.ma)
  final regex = RegExp(r"^[\w\-.]+@([\w\-]+\.)+[a-zA-Z]{2,}");
  return regex.hasMatch(email);
}
