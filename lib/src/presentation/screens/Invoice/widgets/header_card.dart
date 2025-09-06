// ===== Header (Invoice No + Date) ===========================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderCard extends StatelessWidget {
  final String invoiceNo;
  final DateTime date;
  final VoidCallback onPickDate;
  const HeaderCard({required this.invoiceNo, required this.date, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 480;
                  final vPad = isWide ? 10.0 : 8.0;     // vertical padding
                  final fSize = isWide ? 15.0 : 14.0;   // text size
                  final iSize = isWide ? 20.0 : 18.0;   // icon size

                  return TextFormField(
                    readOnly: true,
                    initialValue: invoiceNo,
                    maxLines: 1,
                    style: TextStyle(fontSize: fSize),
                    decoration: InputDecoration(
                      isDense: true, // makes the field more compact
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
                      labelText: 'Invoice No.',
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.confirmation_number_outlined, size: iSize),
                      // shrink the icon’s reserved box so overall height drops
                      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(df.format(date)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}