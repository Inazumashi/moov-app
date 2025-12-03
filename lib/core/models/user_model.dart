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

  // 👇 C'EST ICI QUE TOUT SE JOUE (La traduction Backend -> Frontend)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // ID : Convertit en string au cas où le backend envoie un nombre
      uid: json['id']?.toString() ?? '',
      
      email: json['email'] ?? '',
      
      // ✅ CORRECTION 1 : On combine Prénom + Nom pour faire le fullName
      fullName: "${json['first_name'] ?? ''} ${json['last_name'] ?? ''}".trim(),
      
      // ✅ CORRECTION 2 : Le backend renvoie 'university' (ou 'university_id' parfois)
      universityId: json['university'] ?? json['university_id'] ?? '',
      
      // ✅ CORRECTION 3 : Le backend renvoie 'profile_type' (snake_case)
      profileType: json['profile_type'] ?? json['role'] ?? '',
      
      // ✅ CORRECTION 4 : Le backend renvoie 'phone'
      phoneNumber: json['phone'] ?? json['phoneNumber'],
      
      // Gestion robuste des nombres (int ou double)
      averageRating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : (json['rating'] as double?) ?? 0.0,
          
      ridesCompleted: json['rides_count'] ?? json['total_trips'] ?? 0,
      isPremium: json['is_premium'] ?? false,
    );
  }

  // Pour envoyer des données (si besoin)
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