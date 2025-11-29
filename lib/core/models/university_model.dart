// File: lib/core/models/university_model.dart
class UniversityModel {
  final String universityId;
  final String name;
  final int studentCount;
  final String domain;

  UniversityModel({
    required this.universityId,
    required this.name,
    required this.studentCount,
    required this.domain,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      universityId: json['universityId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      studentCount: json['studentCount'] ?? 0,
      domain: json['domain'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'universityId': universityId,
      'name': name,
      'studentCount': studentCount,
      'domain': domain,
    };
  }
}