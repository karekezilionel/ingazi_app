import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/themes/app_theme.dart';
import 'applicant_detail_screen.dart';

class ApplicantsScreen extends ConsumerStatefulWidget {
  final String opportunityId;
  final String opportunityTitle;

  const ApplicantsScreen({
    super.key,
    required this.opportunityId,
    required this.opportunityTitle,
  });

  @override
  ConsumerState<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends ConsumerState<ApplicantsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Applicants - ${widget.opportunityTitle}',
          style: const TextStyle(
            fontSize: 18,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: _buildApplicantsList(),
    );
  }

  Widget _buildApplicantsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('opportunityId', isEqualTo: widget.opportunityId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
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
                  'Error loading applicants: ${snapshot.error}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'No applicants yet',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Students will appear here when they apply',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        final applicants = snapshot.data!.docs;

        // Sort locally by appliedAt
        final sortedApplicants = applicants.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = aData['appliedAt'] as Timestamp?;
            final bDate = bData['appliedAt'] as Timestamp?;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedApplicants.length,
          itemBuilder: (context, index) {
            final doc = sortedApplicants[index];
            final data = doc.data() as Map<String, dynamic>;
            final applicationId = doc.id;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplicantDetailScreen(
                      applicationId: applicationId,
                    ),
                  ),
                );
              },
              child: _buildApplicantCard(data, applicationId),
            );
          },
        );
      },
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> data, String applicationId) {
    final status = data['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusDisplay = _getStatusDisplay(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['studentName'] ?? 'Student',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      data['studentEmail'] ?? 'No email',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActionButton(
                label: 'View Details',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicantDetailScreen(
                        applicationId: applicationId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildStatusButton(
                label: 'Accept',
                color: AppColors.success,
                onTap: () => _updateStatus(applicationId, 'accepted'),
              ),
              const SizedBox(width: 8),
              _buildStatusButton(
                label: 'Reject',
                color: AppColors.error,
                onTap: () => _updateStatus(applicationId, 'rejected'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get the application data to create notification
      final appData = await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .get();
      final data = appData.data() as Map<String, dynamic>;

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

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
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

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide(color: color),
        foregroundColor: color,
        textStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide(color: color),
        foregroundColor: color,
        textStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
}