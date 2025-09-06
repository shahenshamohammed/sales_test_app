
import 'package:flutter/material.dart';

class HeaderStrip extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPickRange;
  const HeaderStrip({required this.title, required this.subtitle, required this.onPickRange});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.table_chart_outlined),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: OutlinedButton.icon(
          onPressed: onPickRange,
          icon: const Icon(Icons.event_outlined),
          label: const Text('Change Range'),
        ),
      ),
    );
  }
}