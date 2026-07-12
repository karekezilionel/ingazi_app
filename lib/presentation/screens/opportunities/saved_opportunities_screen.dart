import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/opportunity_model.dart';
import 'detail_screen.dart';

class SavedOpportunitiesScreen extends ConsumerStatefulWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  ConsumerState<SavedOpportunitiesScreen> createState() => _SavedOpportunitiesScreenState();
}

class _SavedOpportunitiesScreenState extends ConsumerState<SavedOpportunitiesScreen> {
  List<DocumentSnapshot> _savedOpportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedOpportunities();
  }

  Future<void> _loadSavedOpportunities() async {
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get all saved opportunity IDs for this user
      final savedSnapshot = await FirebaseFirestore.instance
          .collection('saved')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (savedSnapshot.docs.isEmpty) {
        setState(() {
          _savedOpportunities = [];
          _isLoading = false;
        });
        return;
      }

      // Get the actual opportunity documents
      final List<Future<DocumentSnapshot>> futures = [];
      for (var doc in savedSnapshot.docs) {
        final oppId = doc['opportunityId'];
        futures.add(
          FirebaseFirestore.instance.collection('opportunities').doc(oppId).get()
        );
      }

      final results = await Future.wait(futures);
      
      setState(() {
        _savedOpportunities = results.where((doc) => doc.exists).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error loading saved opportunities: $e',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _removeSaved(String opportunityId) async {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('saved')
          .where('userId', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opportunityId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _savedOpportunities.removeWhere((doc) => doc.id == opportunityId);
      });

      Fluttertoast.showToast(
        msg: 'Removed from saved',
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error removing: $e',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Saved Opportunities',
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
        body: const Center(
          child: Text(
            'Please sign in to view saved opportunities',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Saved Opportunities',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSavedOpportunities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _savedOpportunities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved opportunities',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save opportunities to view them here',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Browse Opportunities'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedOpportunities.length,
                  itemBuilder: (context, index) {
                    final doc = _savedOpportunities[index];
                    final opp = OpportunityModel.fromFirestore(doc);
                    return _buildSavedCard(context, opp);
                  },
                ),
    );
  }

  Widget _buildSavedCard(BuildContext context, OpportunityModel opp) {
    final categoryDisplay = opp.category.toString().split('.').last.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.work_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      opportunityId: opp.opportunityId,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opp.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        opp.location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          categoryDisplay,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => _removeSaved(opp.opportunityId),
          ),
        ],
      ),
    );
  }
}