import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../providers/auth_provider.dart';
import 'detail_screen.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _savedIds = [];

  @override
  void initState() {
    super.initState();
    _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('saved')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      _savedIds = snapshot.docs.map((doc) => doc['opportunityId'] as String).toList();
    });
  }

  Future<void> _toggleSaved(OpportunityModel opp) async {
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      Fluttertoast.showToast(
        msg: 'Please sign in to save',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }

    final isSaved = _savedIds.contains(opp.opportunityId);

    if (isSaved) {
      final snapshot = await FirebaseFirestore.instance
          .collection('saved')
          .where('userId', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opp.opportunityId)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {
        _savedIds.remove(opp.opportunityId);
      });
      Fluttertoast.showToast(
        msg: 'Removed from saved',
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
      );
    } else {
      await FirebaseFirestore.instance.collection('saved').add({
        'userId': user.uid,
        'opportunityId': opp.opportunityId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _savedIds.add(opp.opportunityId);
      });
      Fluttertoast.showToast(
        msg: 'Saved!',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get categories => const [
    'All',
    'Design',
    'Engineering',
    'Marketing',
    'Data',
    'Research',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Browse Opportunities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadSavedIds();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search opportunities...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildOpportunitiesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunitiesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('opportunities')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppColors.textSecondary),
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 16),
                Text(
                  'No opportunities found',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add opportunities to Firestore',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        final allOpportunities = snapshot.data!.docs.map((doc) {
          final opp = OpportunityModel.fromFirestore(doc);
          opp.isSaved = _savedIds.contains(opp.opportunityId);
          return opp;
        }).toList();

        List<OpportunityModel> filtered = [];
        if (_selectedCategory == 'All') {
          filtered = allOpportunities;
        } else {
          filtered = allOpportunities.where((opp) {
            final categoryName = opp.category.toString().split('.').last;
            return categoryName.toLowerCase() == _selectedCategory.toLowerCase();
          }).toList();
        }

        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((opp) {
            return opp.title.toLowerCase().contains(_searchQuery) ||
                opp.description.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (filtered.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 16),
                Text(
                  'No matching opportunities',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final opp = filtered[index];
            return _buildOpportunityCard(opp);
          },
        );
      },
    );
  }

  Widget _buildOpportunityCard(OpportunityModel opp) {
    final categoryDisplay = opp.category.toString().split('.').last.toUpperCase();
    final isSaved = _savedIds.contains(opp.opportunityId);

    return GestureDetector(
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
      child: Container(
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
                  child: Text(
                    opp.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categoryDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? AppColors.primary : AppColors.textMuted,
                        size: 22,
                      ),
                      onPressed: () => _toggleSaved(opp),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              opp.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  opp.location,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  opp.hoursPerWeek,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: opp.skills.take(3).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}