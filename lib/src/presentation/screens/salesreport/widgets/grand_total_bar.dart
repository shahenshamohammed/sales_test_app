
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pinned bottom grand total (non-scrollable)
class GrandTotalBar extends StatelessWidget {
  final double total;
  const GrandTotalBar({required this.total});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '\$');
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Expanded(child: Text('Grand Total', style: TextStyle(fontWeight: FontWeight.w800))),
            Text(money.format(total), style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}