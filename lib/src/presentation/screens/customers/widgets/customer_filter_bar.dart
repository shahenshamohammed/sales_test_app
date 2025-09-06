import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String? areaId;
  final String? categoryId;
  final String? search;
  final ValueChanged<String?> onAreaChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onSearch;

  const FilterBar({
    super.key,
    required this.areaId,
    required this.categoryId,
    required this.search,
    required this.onAreaChanged,
    required this.onCategoryChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            // Search
            Expanded(
              flex: 2,
              child: TextField(
                controller: TextEditingController(text: search ?? '')
                  ..selection = TextSelection.collapsed(offset: (search ?? '').length),
                onSubmitted: onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Area
            Expanded(
              child: _RefDropdown(
                label: 'Area',
                collection: 'customerAreas',
                value: areaId,
                onChanged: onAreaChanged,
              ),
            ),
            const SizedBox(width: 8),
            // Category
            Expanded(
              child: _RefDropdown(
                label: 'Category',
                collection: 'customerCategories',
                value: categoryId,
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Clear filters',
              onPressed: () {
                onAreaChanged(null);
                onCategoryChanged(null);
                onSearch(null);
              },
              icon: Icon(Icons.filter_alt_off, color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefDropdown extends StatelessWidget {
  final String collection;
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _RefDropdown({
    required this.collection,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection(collection).orderBy('name');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        final items = <DropdownMenuItem<String>>[
          const DropdownMenuItem(value: null, child: Text('All')),
        ];

        if (snap.hasData) {
          for (final d in snap.data!.docs) {
            items.add(DropdownMenuItem(value: d.id, child: Text(d['name'] as String)));
          }
        }

        return DropdownButtonFormField<String>(
          value: value,
          isDense: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            isDense: true,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        );
      },
    );
  }
}
