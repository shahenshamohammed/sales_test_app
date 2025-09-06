
import 'package:flutter/material.dart';

class TotalsBar extends StatelessWidget {
  final int totalItems; final double total; final VoidCallback onCancel; final VoidCallback? onSave; final bool saving;
  const TotalsBar({required this.totalItems, required this.total, required this.onCancel, required this.onSave, required this.saving});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Items: $totalItems'),
            Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary)),
          ]),
          const Spacer(),
          OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: onSave,
            icon: saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
            label: const Text('Save Invoice'),
          ),
        ]),
      ),
    );
  }
}