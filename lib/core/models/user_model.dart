// File: lib/core/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String universityId;
  final String profileType;
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

  // --- C'EST CETTE PARTIE QUI MANQUAIT OU ÉTAIT INCORRECTE ---
  
  // Factory : Crée un objet UserModel à partir d'un JSON (reçu de l'API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // On convertit les données reçues (API) vers nos variables (Flutter)
      // Note : 'id', 'email', 'fullName' doivent correspondre à ce que votre 
      // API Node.js renvoie dans le auth.controller.js
      uid: json['id']?.toString() ?? '', 
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      universityId: json['university'] ?? '',
      profileType: json['profileType'] ?? '',
      phoneNumber: json['phoneNumber'],
      
      // Conversion sécurisée pour les nombres (parfois reçus en int, parfois en double)
      averageRating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : (json['rating'] as double?) ?? 0.0,
          
      ridesCompleted: json['rides_count'] ?? 0,
      isPremium: json['is_premium'] ?? false,
    );
  }

  // Fonction : Convertit un objet UserModel vers un JSON (pour l'envoyer à l'API)
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