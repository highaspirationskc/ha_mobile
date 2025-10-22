// lib/presentation/widgets/bottom_sheet_pulse.dart
import 'package:flutter/material.dart';
import 'package:ha_mobile/presentation/widgets/button_long.dart';
import 'package:ha_mobile/presentation/widgets/button_long_outlined.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../core/session.dart';
import '../../data/services/api_service.dart';

class BottomSheetPulse extends StatefulWidget {
  const BottomSheetPulse({super.key});

  @override
  State<BottomSheetPulse> createState() => _BottomSheetPulseState();
}

class _BottomSheetPulseState extends State<BottomSheetPulse> {
  final _formKey = GlobalKey<FormState>();
  final _highlightController = TextEditingController();
  final _challengeController = TextEditingController();
  final _thoughtsController = TextEditingController();

  int _rating = 3; // Default to middle rating
  final Set<SupportTopic> _selectedTopics = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _highlightController.dispose();
    _challengeController.dispose();
    _thoughtsController.dispose();
    super.dispose();
  }

  Future<void> _submitPulse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one support topic'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.instance.createPulse(
        userId: currentUserId,
        rating: _rating,
        highlight: _highlightController.text.trim(),
        challenge: _challengeController.text.trim(),
        thoughts: _thoughtsController.text.trim(),
        supportTopics: _selectedTopics.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pulse submitted successfully!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting pulse: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What\'s the Pulse?',
                            style: t.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Share how your week is going',
                            style: t.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Rating Section
                Text(
                  'How has your week been?',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          starIndex <= _rating ? Icons.star : Icons.star_border,
                          color: cs.primary,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Highlight Section
                Text(
                  'What was a highlight of the week?',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _highlightController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share something positive that happened...',
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    filled: true,
                    fillColor: cs.surfaceVariant.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please share a highlight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Challenge Section
                Text(
                  'What was a challenge you faced this week?',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _challengeController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe any difficulties you encountered...',
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    filled: true,
                    fillColor: cs.surfaceVariant.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe a challenge';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Thoughts Section
                Text(
                  'What\'s been on your mind?',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _thoughtsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share any thoughts or concerns...',
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    filled: true,
                    fillColor: cs.surfaceVariant.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please share your thoughts';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Support Topics Section
                Text(
                  'What would you like support with?',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SupportTopic.values.map((topic) {
                    final isSelected = _selectedTopics.contains(topic);
                    return FilterChip(
                      label: Text(_getTopicLabel(topic)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTopics.add(topic);
                          } else {
                            _selectedTopics.remove(topic);
                          }
                        });
                      },
                      selectedColor: cs.primaryContainer,
                      checkmarkColor: cs.onPrimaryContainer,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ButtonLong(
                  label: 'Save Pulse',
                  onPressed: _isSubmitting ? null : _submitPulse,
                ),
                const SizedBox(height: 12),
                ButtonLongOutlined(
                  label: 'Cancel',
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTopicLabel(SupportTopic topic) {
    switch (topic) {
      case SupportTopic.school:
        return 'School';
      case SupportTopic.work:
        return 'Work';
      case SupportTopic.home:
        return 'Home';
      case SupportTopic.relationships:
        return 'Relationships';
      case SupportTopic.health:
        return 'Health';
      case SupportTopic.other:
        return 'Other';
    }
  }
}
