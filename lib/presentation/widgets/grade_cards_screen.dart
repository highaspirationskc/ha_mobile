import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../business/grade_cards/entities/grade_card.dart';
import '../../core/theme/brand_colors.dart';
import '../../data/services/api_service.dart';

/// Centralized Grade Cards Screen that can be used by mentees and guardians.
///
/// - [menteeUserId]: The user ID of the mentee (for fetching grade cards)
/// - [menteeId]: The mentee record ID (for creating grade cards, can be fetched if not provided)
/// - [menteeName]: Optional name for the title. If null, shows "Grade Cards"
/// - [canEdit]: Whether the user can add/delete grade cards (true for mentees and guardians)
class GradeCardsScreen extends StatefulWidget {
  final String menteeUserId;
  final String? menteeId;
  final String? menteeName;
  final bool canEdit;

  const GradeCardsScreen({
    super.key,
    required this.menteeUserId,
    this.menteeId,
    this.menteeName,
    this.canEdit = false,
  });

  @override
  State<GradeCardsScreen> createState() => _GradeCardsScreenState();
}

class _GradeCardsScreenState extends State<GradeCardsScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  List<GradeCard> _gradeCards = [];
  String? _resolvedMenteeId;

  @override
  void initState() {
    super.initState();
    _resolvedMenteeId = widget.menteeId;
    _loadGradeCards();
    ApiService.instance.changes.addListener(_onApiChanges);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChanges);
    super.dispose();
  }

  void _onApiChanges() {
    _loadGradeCards();
  }

  Future<void> _loadGradeCards() async {
    try {
      final gradeCards = await ApiService.instance.getGradeCards(
        userId: widget.menteeUserId,
        forceRefresh: true,
      );

      // If we don't have menteeId yet and canEdit is true, fetch it
      if (_resolvedMenteeId == null && widget.canEdit) {
        final menteeData = await ApiService.instance.getMenteeData(
          userId: widget.menteeUserId,
        );
        _resolvedMenteeId = menteeData?.menteeId;
      }

      if (mounted) {
        setState(() {
          _gradeCards = gradeCards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAddGradeCard() async {
    if (_resolvedMenteeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not determine mentee ID'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final picker = ImagePicker();

    // Show options for camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final xFile = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (xFile == null) return;

      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name.isNotEmpty ? xFile.name : 'grade_card.jpg';

      // Show confirmation bottom sheet with preview and description
      if (!mounted) return;
      final result = await _showUploadConfirmationSheet(bytes);

      if (result == null) return; // User cancelled

      setState(() => _isProcessing = true);

      await ApiService.instance.createGradeCard(
        menteeId: _resolvedMenteeId!,
        imageBytes: bytes,
        fileName: fileName,
        description: result.isNotEmpty ? result : null,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade card added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add grade card: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<String?> _showUploadConfirmationSheet(Uint8List imageBytes) async {
    final descriptionController = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UploadConfirmationSheet(
        imageBytes: imageBytes,
        descriptionController: descriptionController,
      ),
    );
  }

  void _showGradeCardDetail(GradeCard gradeCard) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final maxHeight = MediaQuery.of(dialogContext).size.height * 0.6;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxHeight),
                        child: Image.network(
                          gradeCard.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (gradeCard.description != null &&
                            gradeCard.description!.isNotEmpty) ...[
                          Text(
                            gradeCard.description!,
                            style: Theme.of(dialogContext).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          'Added ${_formatDate(gradeCard.createdAt)}',
                          style: Theme.of(dialogContext).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  dialogContext,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.canEdit) ...[
              const SizedBox(height: 16),
              // Delete button below the card
              TextButton.icon(
                onPressed: () =>
                    _confirmDeleteGradeCard(dialogContext, gradeCard),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteGradeCard(
    BuildContext dialogContext,
    GradeCard gradeCard,
  ) async {
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade Card'),
        content: const Text(
          'Are you sure you want to delete this grade card? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Close the detail dialog
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    try {
      setState(() => _isProcessing = true);

      await ApiService.instance.deleteGradeCard(
        gradeCardId: gradeCard.id,
        userId: widget.menteeUserId,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade card deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String get _title {
    if (widget.menteeName != null) {
      return '${widget.menteeName}\'s Grade Cards';
    }
    return 'Grade Cards';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with + button (only if canEdit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _title,
                              style: t.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (widget.canEdit)
                            IconButton(
                              onPressed: _isProcessing
                                  ? null
                                  : _handleAddGradeCard,
                              icon: _isProcessing
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kHAPrimary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add,
                                      color: kHAPrimary,
                                      size: 28,
                                    ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Grade Cards Grid
                      if (_gradeCards.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: cs.outlineVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No grade cards submitted yet',
                                  style: t.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                if (widget.canEdit) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add a grade card',
                                    style: t.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: _gradeCards.length,
                          itemBuilder: (context, index) {
                            final gradeCard = _gradeCards[index];
                            return _buildGradeCardTile(gradeCard, cs, t);
                          },
                        ),
                    ],
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Processing...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildGradeCardTile(GradeCard gradeCard, ColorScheme cs, TextTheme t) {
    return GestureDetector(
      onTap: () => _showGradeCardDetail(gradeCard),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  gradeCard.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: cs.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: cs.onSurfaceVariant,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Description and date footer
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gradeCard.description != null &&
                      gradeCard.description!.isNotEmpty)
                    Text(
                      gradeCard.description!,
                      style: t.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    _formatDate(gradeCard.createdAt),
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for confirming grade card upload with preview and description
class _UploadConfirmationSheet extends StatelessWidget {
  final Uint8List imageBytes;
  final TextEditingController descriptionController;

  const _UploadConfirmationSheet({
    required this.imageBytes,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Add Grade Card',
                style: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Image preview
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 250,
                      maxWidth: double.infinity,
                    ),
                    child: Image.memory(imageBytes, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description field
              Text(
                'Description (optional)',
                style: t.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'e.g., Fall 2024 Report Card',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context, descriptionController.text);
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload'),
                      style: FilledButton.styleFrom(
                        backgroundColor: kHAPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
