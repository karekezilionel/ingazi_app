import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/themes/app_theme.dart';

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicantDetailScreen({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  Map<String, dynamic>? _applicationData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplicationDetails();
  }

  Future<void> _loadApplicationDetails() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId)
          .get();

      if (doc.exists) {
        setState(() {
          _applicationData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Application not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading details: $e';
        _isLoading = false;
      });
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'reviewing':
        return 'Under Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewing':
        return Colors.blue;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      // Update application status
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get the application data to know who to notify
      final appData = await FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId)
          .get();
      final data = appData.data() as Map<String, dynamic>;

      // Create notification for the student
      final statusDisplay = newStatus == 'accepted' ? 'accepted' : 'rejected';
      final emoji = newStatus == 'accepted' ? '🎉' : '😔';
      
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': data['studentId'],
        'title': 'Application ${newStatus.toUpperCase()}',
        'message': '$emoji Your application for "${data['opportunityTitle']}" was $statusDisplay!',
        'type': 'application_status',
        'read': false,
        'data': {
          'opportunityId': data['opportunityId'],
          'status': newStatus,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _applicationData?['status'] = newStatus;
      });

      Fluttertoast.showToast(
        msg: 'Application ${newStatus.toUpperCase()}!',
        backgroundColor: newStatus == 'accepted' ? AppColors.success : AppColors.error,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error updating status: $e',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Applicant Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadApplicationDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Student Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Student Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              label: 'Name',
                              value: _applicationData?['studentName'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              label: 'Email',
                              value: _applicationData?['studentEmail'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              label: 'Applied On',
                              value: _formatDate(_applicationData?['appliedAt']),
                            ),
                            _buildInfoRow(
                              label: 'Status',
                              value: _getStatusDisplay(_applicationData?['status'] ?? 'pending'),
                              valueColor: _getStatusColor(_applicationData?['status'] ?? 'pending'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Message
                      if (_applicationData?['message'] != null &&
                          _applicationData!['message'].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cover Letter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _applicationData?['message'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Status Update Buttons
                      if (_applicationData?['status'] == 'pending' ||
                          _applicationData?['status'] == 'reviewing')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateStatus('accepted'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                                child: const Text('Accept'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateStatus('rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    }
    return 'N/A';
  }
}