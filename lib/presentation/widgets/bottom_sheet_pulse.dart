// lib/presentation/widgets/bottom_sheet_pulse.dart
import 'package:flutter/material.dart';
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header with X and Save buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                  const Spacer(),
                  // Save button
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitPulse,
                    icon: const Icon(Icons.check),
                    tooltip: 'Save',
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'How\'s your week going?',
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share how your week is going',
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),

                    // Rating Section
                    Text(
                      'How has your week been?',
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
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
                              starIndex <= _rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: cs.primary,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: cs.outlineVariant.withOpacity(0.5)),

                    // Highlight Section
                    const SizedBox(height: 8),
                    Text(
                      'Highlight:',
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _highlightController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share something positive that happened...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please share a highlight';
                        }
                        return null;
                      },
                    ),

                    Divider(color: cs.outlineVariant.withOpacity(0.5)),

                    // Challenge Section
                    const SizedBox(height: 8),
                    Text(
                      'Challenge:',
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _challengeController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe any difficulties you encountered...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe a challenge';
                        }
                        return null;
                      },
                    ),

                    Divider(color: cs.outlineVariant.withOpacity(0.5)),

                    // Thoughts Section
                    const SizedBox(height: 8),
                    Text(
                      'On Your Mind:',
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _thoughtsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share any thoughts or concerns...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please share your thoughts';
                        }
                        return null;
                      },
                    ),

                    Divider(color: cs.outlineVariant.withOpacity(0.5)),
                    const SizedBox(height: 8),

                    // Support Topics Section
                    Text(
                      'Support Topics:',
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
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
                  ],
                ),
              ),
            ),
          ],
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
