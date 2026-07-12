import 'package:cloud_firestore/cloud_firestore.dart';

enum StartupCategory {
  edtech,
  fintech,
  health,
  socialImpact,
  tech,
  other,
}

class StartupModel {
  final String startupId;
  final String name;
  final String description;
  final String? logo;
  final StartupCategory category;
  final String representativeId;
  final List<String> members;
  final bool verified;
  final String verificationStatus;
  final String? website;
  final DateTime createdAt;
  final DateTime updatedAt;

  StartupModel({
    required this.startupId,
    required this.name,
    required this.description,
    this.logo,
    required this.category,
    required this.representativeId,
    this.members = const [],
    this.verified = false,
    this.verificationStatus = 'pending',
    this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StartupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StartupModel(
      startupId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logo: data['logo'],
      category: _stringToCategory(data['category'] ?? 'other'),
      representativeId: data['representativeId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      verified: data['verified'] ?? false,
      verificationStatus: data['verificationStatus'] ?? 'pending',
      website: data['website'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'category': categoryToString(category),
      'representativeId': representativeId,
      'members': members,
      'verified': verified,
      'verificationStatus': verificationStatus,
      'website': website,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static StartupCategory _stringToCategory(String value) {
    switch (value.toLowerCase()) {
      case 'edtech':
        return StartupCategory.edtech;
      case 'fintech':
        return StartupCategory.fintech;
      case 'health':
        return StartupCategory.health;
      case 'socialimpact':
        return StartupCategory.socialImpact;
      case 'tech':
        return StartupCategory.tech;
      default:
        return StartupCategory.other;
    }
  }

  static String categoryToString(StartupCategory category) {
    switch (category) {
      case StartupCategory.edtech:
        return 'edtech';
      case StartupCategory.fintech:
        return 'fintech';
      case StartupCategory.health:
        return 'health';
      case StartupCategory.socialImpact:
        return 'socialImpact';
      case StartupCategory.tech:
        return 'tech';
      case StartupCategory.other:
        return 'other';
    }
  }
}