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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      universityId: json['universityId'] ?? '',
      profileType: json['profileType'] ?? 'Étudiant',
      phoneNumber: json['phoneNumber'],
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      ridesCompleted: json['ridesCompleted'] ?? 0,
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'universityId': universityId,
      'profileType': profileType,
      'phoneNumber': phoneNumber,
      'averageRating': averageRating,
      'ridesCompleted': ridesCompleted,
      'isPremium': isPremium,
    };
  }
}