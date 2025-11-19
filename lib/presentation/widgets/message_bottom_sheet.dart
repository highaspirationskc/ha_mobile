// lib/presentation/widgets/message_bottom_sheet.dart
import 'package:flutter/material.dart';

class MessageBottomSheet extends StatefulWidget {
  final String? recipientName;
  final String? recipientId;

  const MessageBottomSheet({super.key, this.recipientName, this.recipientId});

  @override
  State<MessageBottomSheet> createState() => _MessageBottomSheetState();
}

class _MessageBottomSheetState extends State<MessageBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill recipient if provided
    if (widget.recipientName != null) {
      _toController.text = widget.recipientName!;
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState?.validate() ?? false) {
      // Log the data
      debugPrint('=== New Message ===');
      debugPrint('To: ${_toController.text}');
      debugPrint('Recipient ID: ${widget.recipientId}');
      debugPrint('Subject: ${_subjectController.text}');
      debugPrint('Message: ${_messageController.text}');
      debugPrint('==================');

      // Show success message and close
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header with X and Send buttons
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
                  // Send button
                  IconButton(
                    onPressed: _handleSend,
                    icon: const Icon(Icons.send),
                    tooltip: 'Send',
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
                      'New Message',
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // To field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'To:',
                          style: t.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _toController,
                            decoration: const InputDecoration(
                              hintText: 'Recipient name',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a recipient';
                              }
                              return null;
                            },
                            readOnly: widget.recipientName != null,
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    Divider(color: cs.outlineVariant.withOpacity(0.5)),

                    // Subject field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Subject:',
                          style: t.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _subjectController,
                            decoration: const InputDecoration(
                              hintText: 'Message subject',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a subject';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    Divider(color: cs.outlineVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),

                    // Message body field
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      minLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
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
}

/// Helper function to show the message bottom sheet
void showMessageBottomSheet(
  BuildContext context, {
  String? recipientName,
  String? recipientId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (context) => MessageBottomSheet(
      recipientName: recipientName,
      recipientId: recipientId,
    ),
  );
}
