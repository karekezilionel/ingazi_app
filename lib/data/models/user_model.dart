import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  startup,
  admin,
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? profileImage;
  final String? bio;
  final List<String> skills;
  final String? major;
  final int? graduationYear;
  final String? startupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    this.bio,
    this.skills = const [],
    this.major,
    this.graduationYear,
    this.startupId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: _stringToRole(data['role'] ?? 'student'),
      profileImage: data['profileImage'],
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
      major: data['major'],
      graduationYear: data['graduationYear'],
      startupId: data['startupId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': roleToString(role),
      'profileImage': profileImage,
      'bio': bio,
      'skills': skills,
      'major': major,
      'graduationYear': graduationYear,
      'startupId': startupId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static UserRole _stringToRole(String role) {
    switch (role.toLowerCase()) {
      case 'startup':
        return UserRole.startup;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'student';
      case UserRole.startup:
        return 'startup';
      case UserRole.admin:
        return 'admin';
    }
  }

  bool get isStudent => role == UserRole.student;
  bool get isStartup => role == UserRole.startup;
  bool get isAdmin => role == UserRole.admin;
}