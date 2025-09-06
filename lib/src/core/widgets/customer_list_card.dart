import 'package:flutter/material.dart';

import '../../data/models/customers.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.primaryContainer,
              child: Text(_initials(customer.name),
                  style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(customer.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: -8,
                    children: [
                      if (customer.areaName != null && customer.areaName!.isNotEmpty)
                        _chip(Icons.place_outlined, customer.areaName!),
                      if (customer.categoryName != null && customer.categoryName!.isNotEmpty)
                        _chip(Icons.category_outlined, customer.categoryName!),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Open',
              onPressed: () {
                // TODO: navigate to details/edit if you have routes
                // context.go('/customers/${customer.docId}');
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Widget _chip(IconData ic, String text) {
    return Chip(
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      avatar: Icon(ic, size: 16),
      label: Text(text),
    );
  }
}
