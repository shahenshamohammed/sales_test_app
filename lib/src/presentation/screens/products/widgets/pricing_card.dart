
import 'package:flutter/material.dart';

class PricingCard extends StatelessWidget {
  final TextEditingController purchaseCtrl;
  final TextEditingController salesCtrl;
  final ValueChanged<String> onPurchaseChanged;
  final ValueChanged<String> onSalesChanged;

  const PricingCard({
    required this.purchaseCtrl,
    required this.salesCtrl,
    required this.onPurchaseChanged,
    required this.onSalesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pricing', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            isWide
                ? Row(
              children: [
                Expanded(child: _rateField(purchaseCtrl, 'Purchase Rate *', onPurchaseChanged)),
                const SizedBox(width: 12),
                Expanded(child: _rateField(salesCtrl, 'Sales Rate *', onSalesChanged)),
              ],
            )
                : Column(
              children: [
                _rateField(purchaseCtrl, 'Purchase Rate *', onPurchaseChanged),
                const SizedBox(height: 12),
                _rateField(salesCtrl, 'Sales Rate *', onSalesChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateField(TextEditingController c, String label, ValueChanged<String> onChanged) {
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.attach_money), filled: true),
      validator: (v) {
        final d = double.tryParse((v ?? '').trim());
        if (d == null || d < 0) return 'Enter a valid amount';
        return null;
      },
      onChanged: onChanged,
    );
  }
}