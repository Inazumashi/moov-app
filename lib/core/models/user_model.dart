class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String universityId;
  final String profileType; // 'Étudiant', 'Enseignant', etc.
  final String? phoneNumber;
  final double averageRating;
  final int ridesCompleted;
  final bool isPremium;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.universityId,
    required this.profileType,
    this.phoneNumber,
    this.averageRating = 0.0,
    this.ridesCompleted = 0,
    this.isPremium = false,
  });

  // Ici, on ajoutera plus tard des fonctions
  // pour convertir ce modèle depuis/vers JSON (pour Firebase)
}
