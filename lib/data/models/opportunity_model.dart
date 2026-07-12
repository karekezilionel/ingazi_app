import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityCategory {
  design,
  engineering,
  marketing,
  data,
  research,
  other,
}

enum Commitment {
  partTime,
  fullTime,
  projectBased,
}

class OpportunityModel {
  final String opportunityId;
  final String startupId;
  final String title;
  final String description;
  final OpportunityCategory category;
  final List<String> skills;
  final Commitment commitment;
  final String hoursPerWeek;
  final String location;
  final bool isActive;
  final DateTime? createdAt;
  final int applicationsCount;
  bool isSaved;

  OpportunityModel({
    required this.opportunityId,
    required this.startupId,
    required this.title,
    required this.description,
    required this.category,
    this.skills = const [],
    this.commitment = Commitment.partTime,
    required this.hoursPerWeek,
    required this.location,
    this.isActive = true,
    this.createdAt,
    this.applicationsCount = 0,
    this.isSaved = false,
  });

  factory OpportunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OpportunityModel(
      opportunityId: doc.id,
      startupId: data['startupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: _stringToCategory(data['category'] ?? 'other'),
      skills: List<String>.from(data['skills'] ?? []),
      commitment: _stringToCommitment(data['commitment'] ?? 'partTime'),
      hoursPerWeek: data['hoursPerWeek'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      applicationsCount: data['applicationsCount'] ?? 0,
      isSaved: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startupId': startupId,
      'title': title,
      'description': description,
      'category': categoryToString(category),
      'skills': skills,
      'commitment': commitmentToString(commitment),
      'hoursPerWeek': hoursPerWeek,
      'location': location,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'applicationsCount': applicationsCount,
    };
  }

  static OpportunityCategory _stringToCategory(String value) {
    switch (value.toLowerCase()) {
      case 'design':
        return OpportunityCategory.design;
      case 'engineering':
        return OpportunityCategory.engineering;
      case 'marketing':
        return OpportunityCategory.marketing;
      case 'data':
        return OpportunityCategory.data;
      case 'research':
        return OpportunityCategory.research;
      default:
        return OpportunityCategory.other;
    }
  }

  static String categoryToString(OpportunityCategory category) {
    switch (category) {
      case OpportunityCategory.design:
        return 'design';
      case OpportunityCategory.engineering:
        return 'engineering';
      case OpportunityCategory.marketing:
        return 'marketing';
      case OpportunityCategory.data:
        return 'data';
      case OpportunityCategory.research:
        return 'research';
      case OpportunityCategory.other:
        return 'other';
    }
  }

  static Commitment _stringToCommitment(String value) {
    switch (value.toLowerCase()) {
      case 'fulltime':
        return Commitment.fullTime;
      case 'projectbased':
        return Commitment.projectBased;
      default:
        return Commitment.partTime;
    }
  }

  static String commitmentToString(Commitment commitment) {
    switch (commitment) {
      case Commitment.fullTime:
        return 'fullTime';
      case Commitment.projectBased:
        return 'projectBased';
      default:
        return 'partTime';
    }
  }
}