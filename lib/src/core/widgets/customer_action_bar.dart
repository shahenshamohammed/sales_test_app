// lib/src/presentation/screens/customers/add/widgets/customer_actions_bar.dart
import 'package:flutter/material.dart';

class CustomerActionsBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onReset;

  const CustomerActionsBar({
    super.key,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Customer'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(foregroundColor: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}
