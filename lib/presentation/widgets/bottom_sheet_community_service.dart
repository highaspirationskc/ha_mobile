import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../core/session.dart';

class BottomSheetCommunityService extends StatefulWidget {
  const BottomSheetCommunityService({super.key});

  @override
  State<BottomSheetCommunityService> createState() =>
      _BottomSheetCommunityServiceState();
}

class _BottomSheetCommunityServiceState
    extends State<BottomSheetCommunityService> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _hours = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'Community Service',
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your community service event.',
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              Text(
                'Name',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'What did you do?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: cs.surfaceVariant.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description Field
              Text(
                'Description',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your community service activity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: cs.surfaceVariant.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date Field
              Text(
                'Date',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outline),
                    borderRadius: BorderRadius.circular(12),
                    color: cs.surfaceVariant.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: t.bodyLarge?.copyWith(color: cs.onSurface),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Hours Field
              Text(
                'Hours',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Decrement Button
                  InkWell(
                    onTap: _hours > 0 ? () => setState(() => _hours--) : null,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.remove, color: cs.onPrimary, size: 24),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Hours Display
                  Container(
                    width: 80,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Center(
                      child: Text(
                        _hours.toString().padLeft(2, '0'),
                        style: t.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Increment Button
                  InkWell(
                    onTap: () => setState(() => _hours++),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add, color: cs.onPrimary, size: 24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCommunityService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Save',
                          style: t.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimary,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: t.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveCommunityService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hours == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 1 hour')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.instance.createCommunityService(
        userId: currentUserId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        hours: _hours,
        location: null, // Could add location field later
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community service added successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
