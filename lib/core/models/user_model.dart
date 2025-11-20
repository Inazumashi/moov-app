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

  // --- C'EST CETTE PARTIE QUI MANQUAIT ---
  // Factory constructor pour créer un UserModel depuis une Map (JSON)
  // C'est ce qui permet de lire la réponse de l'API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Note: Les clés ('user_id', 'email') doivent correspondre
      // à ce que votre API Node.js renvoie dans auth.controller.js
      uid: json['id'].toString(), 
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      universityId: json['university'] ?? '',
      profileType: json['profileType'] ?? '',
      phoneNumber: json['phoneNumber'],
      // Conversion sécurisée pour les nombres
      averageRating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : (json['rating'] as double?) ?? 0.0,
      ridesCompleted: json['rides_count'] ?? 0,
      isPremium: json['is_premium'] ?? false,
    );
  }

  // Fonction pour convertir en JSON (utile si on veut envoyer des données)
  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'fullName': fullName,
      'university': universityId,
      'profileType': profileType,
      'phoneNumber': phoneNumber,
    };
  }
}