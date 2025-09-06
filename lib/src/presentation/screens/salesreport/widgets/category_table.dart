import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/sales_grouped_report.dart';

/// Category card → horizontal grid with 5 columns: Code | Name | Qty | Price | Amount
class CategoryTable extends StatelessWidget {
  final CategoryReport category;
  const CategoryTable({required this.category});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '\$');
    final cs = Theme.of(context).colorScheme;

    // Category header (shows Subtotal on the right)
    final header = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_down),
          const SizedBox(width: 4),
          Expanded(
            child: Text(category.categoryName, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(money.format(category.subtotal),
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );

    // Table (scrolls horizontally on small screens)
    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 680),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.1), // Code
            1: FlexColumnWidth(2.6), // Name
            2: FlexColumnWidth(1.0), // Qty
            3: FlexColumnWidth(1.2), // Price
            4: FlexColumnWidth(1.4), // Amount
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _headerRow(context),
            ...category.rows.map((r) => TableRow(children: [
              _cell(context, r.code),
              _cell(context, r.name),
              _cell(context, r.qty.toString()),
              _cell(context, money.format(r.price)),
              _cell(context, money.format(r.amount), alignRight: true),
            ])),
          ],
        ),
      ),
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: [header, table]),
    );
  }

  TableRow _headerRow(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);
    Widget head(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(t, style: style),
    );
    return TableRow(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.25)),
      children: [
        head('Code'),
        head('Name'),
        head('Qty'),
        head('Price'),
        head('Amount'),
      ],
    );
  }

  Widget _cell(BuildContext context, String text, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}