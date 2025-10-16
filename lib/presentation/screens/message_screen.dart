import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final String? messageId;
  const MessageScreen({super.key, this.messageId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Text('Viewing message: ${messageId ?? '(none)'}'),
        ),
      ),
    );
  }
}
