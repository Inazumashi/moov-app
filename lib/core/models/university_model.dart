class UniversityModel {
  final String universityId;
  final String name; // "Université Mohammed VI Polytechnique"
  final int studentCount; // 3200
  final String domain; // "um6p.ma" (pour vérifier l'email)

  UniversityModel({
    required this.universityId,
    required this.name,
    required this.studentCount,
    required this.domain,
  });

  // Ici, on ajoutera plus tard des fonctions
  // pour convertir ce modèle depuis/vers JSON (pour Firebase)
}
