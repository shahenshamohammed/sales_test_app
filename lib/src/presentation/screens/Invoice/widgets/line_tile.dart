// ===== Items list ============================================================
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/invoice_form.dart';

class LinesList extends StatelessWidget {
  final List<LineItem> items;
  final void Function(int index, LineItem li) onChange;
  final void Function(int index) onRemove;
  const LinesList({required this.items, required this.onChange, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No items yet. Tap “Add”.')),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _LineTile(
        item: items[i],
        onChange: (li) => onChange(i, li),
        onRemove: () => onRemove(i),
      ),
    );
  }
}


class _LineTile extends StatelessWidget {
  final LineItem item;
  final ValueChanged<LineItem> onChange;
  final VoidCallback onRemove;
  const _LineTile({required this.item, required this.onChange, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: cs.outlineVariant), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: SizedBox(
          width: 48, height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (item.coverUrl == null || item.coverUrl!.isEmpty)
                ? Container(color: cs.surfaceVariant.withOpacity(.6), child: const Icon(Icons.inventory_2_outlined))
                : CachedNetworkImage(imageUrl: item.coverUrl!, fit: BoxFit.cover),
          ),
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _QtyRateEditor(
            qty: item.qty,
            rate: item.rate,
            onChanged: (q, r) => onChange(item.copyWith(qty: q, rate: r)),
          ),
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 96),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${item.lineTotal.toStringAsFixed(2)}', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary)),
              IconButton(tooltip: 'Remove', splashRadius: 18, onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyRateEditor extends StatefulWidget {
  final double qty;
  final double rate;
  final void Function(double qty, double rate) onChanged;
  const _QtyRateEditor({required this.qty, required this.rate, required this.onChanged});
  @override State<_QtyRateEditor> createState() => _QtyRateEditorState();
}
class _QtyRateEditorState extends State<_QtyRateEditor> {
  late final qty = TextEditingController(text: widget.qty.toStringAsFixed(0));
  late final rate = TextEditingController(text: widget.rate.toStringAsFixed(2));
  @override void dispose(){ qty.dispose(); rate.dispose(); super.dispose(); }
  InputDecoration _dec(String l) => const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), border: OutlineInputBorder()).copyWith(labelText: l);
  @override Widget build(BuildContext context) {
    final qtyField  = SizedBox(width: 72,  child: TextField(controller: qty,  keyboardType: const TextInputType.numberWithOptions(),                 decoration: _dec('Qty'),  onChanged: _emit));
    final rateField = SizedBox(width: 110, child: TextField(controller: rate, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Rate'), onChanged: _emit));
    return LayoutBuilder(builder: (_, c) => c.maxWidth < 220 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children:[qtyField, const SizedBox(height:8), rateField]) : Row(children:[qtyField, const SizedBox(width:8), rateField]));
  }
  void _emit([_]){ final q = double.tryParse(qty.text) ?? 0; final r = double.tryParse(rate.text) ?? 0; widget.onChanged(q, r); }
}