import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ApplicationStatus {
  pending,
  reviewing,
  accepted,
  rejected,
}

class ApplicationModel {
  final String applicationId;
  final String studentId;
  final String opportunityId;
  final String startupId;
  final ApplicationStatus status;
  final String? message;
  final String? notes;
  final DateTime appliedAt;
  final DateTime updatedAt;

  ApplicationModel({
    required this.applicationId,
    required this.studentId,
    required this.opportunityId,
    required this.startupId,
    this.status = ApplicationStatus.pending,
    this.message,
    this.notes,
    required this.appliedAt,
    required this.updatedAt,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: doc.id,
      studentId: data['studentId'] ?? '',
      opportunityId: data['opportunityId'] ?? '',
      startupId: data['startupId'] ?? '',
      status: _stringToStatus(data['status'] ?? 'pending'),
      message: data['message'],
      notes: data['notes'],
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'opportunityId': opportunityId,
      'startupId': startupId,
      'status': statusToString(status),
      'message': message,
      'notes': notes,
      'appliedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static ApplicationStatus _stringToStatus(String value) {
    switch (value.toLowerCase()) {
      case 'reviewing':
        return ApplicationStatus.reviewing;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  static String statusToString(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.reviewing:
        return 'reviewing';
      case ApplicationStatus.accepted:
        return 'accepted';
      case ApplicationStatus.rejected:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  String get statusDisplay {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.reviewing:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.reviewing:
        return Colors.blue;
      case ApplicationStatus.accepted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
    }
  }
}