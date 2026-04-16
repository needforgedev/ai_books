import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/storage/database_helper.dart';
import 'package:ai_books/core/widgets/ai_chip.dart';

class EditInterestsScreen extends StatefulWidget {
  const EditInterestsScreen({
    super.key,
    required this.initialInterests,
    required this.initialGoals,
    required this.initialImprovements,
  });

  final List<String> initialInterests;
  final List<String> initialGoals;
  final List<String> initialImprovements;

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState();
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  late final Set<String> _selectedInterests;
  late final Set<String> _selectedGoals;
  late final Set<String> _selectedImprovements;

  bool _isSaving = false;

  static const List<String> _interestOptions = [
    'Philosophy',
    'Psychology',
    'Self Growth',
    'Spirituality',
    'Business',
    'History',
    'Science',
    'Sociology',
  ];

  static const List<String> _goalOptions = [
    'Build Discipline',
    'Reduce Overthinking',
    'Understand People',
    'Find Purpose',
    'Improve Mindset',
    'Become More Knowledgeable',
    'Think More Clearly',
  ];

  static const List<String> _improvementOptions = [
    'Focus',
    'Confidence',
    'Habits',
    'Emotional Control',
    'Consistency',
    'Productivity',
    'Relationships',
  ];

  @override
  void initState() {
    super.initState();
    _selectedInterests = Set<String>.from(widget.initialInterests);
    _selectedGoals = Set<String>.from(widget.initialGoals);
    _selectedImprovements = Set<String>.from(widget.initialImprovements);
  }

  void _toggleInterest(String item) {
    setState(() {
      if (_selectedInterests.contains(item)) {
        _selectedInterests.remove(item);
      } else {
        _selectedInterests.add(item);
      }
    });
  }

  void _toggleGoal(String item) {
    setState(() {
      if (_selectedGoals.contains(item)) {
        _selectedGoals.remove(item);
      } else {
        _selectedGoals.add(item);
      }
    });
  }

  void _toggleImprovement(String item) {
    setState(() {
      if (_selectedImprovements.contains(item)) {
        _selectedImprovements.remove(item);
      } else {
        _selectedImprovements.add(item);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'user_profile',
      {
        'selected_interests': jsonEncode(_selectedInterests.toList()),
        'selected_goals': jsonEncode(_selectedGoals.toList()),
        'selected_improvement_areas':
            jsonEncode(_selectedImprovements.toList()),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = 1',
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text('EDIT INTERESTS', style: AppTypography.sectionHeading),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Interests section
                    Text('Interests', style: AppTypography.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Pick as many as you like',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _interestOptions.map((option) {
                        return AiChip(
                          label: option,
                          isSelected: _selectedInterests.contains(option),
                          onTap: () => _toggleInterest(option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    // Goals section
                    Text('Goals', style: AppTypography.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Pick as many as you like',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _goalOptions.map((option) {
                        return AiChip(
                          label: option,
                          isSelected: _selectedGoals.contains(option),
                          onTap: () => _toggleGoal(option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    // Areas to Improve section
                    Text('Areas to Improve', style: AppTypography.cardTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Pick as many as you like',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _improvementOptions.map((option) {
                        return AiChip(
                          label: option,
                          isSelected: _selectedImprovements.contains(option),
                          onTap: () => _toggleImprovement(option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.buttonDisabled,
                    disabledForegroundColor: AppColors.textDisabled,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    textStyle: AppTypography.buttonLarge,
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textOnPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('SAVE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
