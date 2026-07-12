import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_theme.dart';

class EditOpportunityScreen extends ConsumerStatefulWidget {
  final String opportunityId;

  const EditOpportunityScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  ConsumerState<EditOpportunityScreen> createState() => _EditOpportunityScreenState();
}

class _EditOpportunityScreenState extends ConsumerState<EditOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _hoursController = TextEditingController();
  final _skillsController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  String _selectedCategory = 'design';
  String _selectedCommitment = 'partTime';

  final List<String> _categories = [
    'design',
    'engineering',
    'marketing',
    'data',
    'research',
    'other',
  ];

  final List<String> _commitments = [
    'partTime',
    'fullTime',
    'projectBased',
  ];

  @override
  void initState() {
    super.initState();
    _loadOpportunity();
  }

  Future<void> _loadOpportunity() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('opportunities')
          .doc(widget.opportunityId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _locationController.text = data['location'] ?? '';
        _hoursController.text = data['hoursPerWeek'] ?? '';
        _selectedCategory = data['category'] ?? 'design';
        _selectedCommitment = data['commitment'] ?? 'partTime';
        final skills = List<String>.from(data['skills'] ?? []);
        _skillsController.text = skills.join(', ');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading opportunity: $e',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await FirebaseFirestore.instance
          .collection('opportunities')
          .doc(widget.opportunityId)
          .update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'hoursPerWeek': _hoursController.text.trim(),
        'commitment': _selectedCommitment,
        'skills': skills,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(
        msg: 'Opportunity updated successfully!',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );

      Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Opportunity',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Opportunity',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update the details of your opportunity',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Opportunity Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Describe the role and responsibilities',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours per Week',
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'e.g., 4-6 hrs/week',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCommitment,
                decoration: const InputDecoration(
                  labelText: 'Commitment Type',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                items: _commitments.map((commitment) {
                  return DropdownMenuItem(
                    value: commitment,
                    child: Text(commitment.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCommitment = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills Required',
                  prefixIcon: Icon(Icons.bolt),
                  hintText: 'e.g., Flutter, Dart, Firebase (comma separated)',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one skill';
                  }
                  final skills = value.split(',').where((s) => s.trim().isNotEmpty);
                  if (skills.isEmpty) {
                    return 'Please enter at least one skill';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateOpportunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Opportunity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}