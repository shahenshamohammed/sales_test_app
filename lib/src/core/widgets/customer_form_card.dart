import 'package:flutter/material.dart';
import 'package:sales_test_app/src/core/widgets/tip_chart.dart';

import '../../data/models/ref_item_int.dart';
import 'customer_section_header.dart';


class CustomerFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController address;

  // NEW: Firestore-driven dropdown data + selections
  final List<RefItem> areas;
  final List<RefItem> categories;
  final RefItem? selectedArea;
  final RefItem? selectedCategory;

  // callbacks
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<RefItem?> onAreaChanged;
  final ValueChanged<RefItem?> onCategoryChanged;

  final double topMargin;
  final double horizontalPadding;

  const CustomerFormCard({
    super.key,
    required this.formKey,
    required this.name,
    required this.address,
    required this.areas,
    required this.categories,
    required this.selectedArea,
    required this.selectedCategory,
    required this.onNameChanged,
    required this.onAddressChanged,
    required this.onAreaChanged,
    required this.onCategoryChanged,
    required this.topMargin,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final w = c.maxWidth;
      final isWide = w >= 980;

      return Card(
        elevation: 6,
        margin: EdgeInsets.only(top: topMargin, left: horizontalPadding, right: horizontalPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: EdgeInsets.all(isWide ? 26 : 18),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Personal Information'),
                const SizedBox(height: 12),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _nameField()),
                      const SizedBox(width: 16),
                      Expanded(child: _addressField()),
                    ],
                  )
                else ...[
                  _nameField(),
                  const SizedBox(height: 12),
                  _addressField(),
                ],

                const SizedBox(height: 20),
                const SectionHeader(title: 'Location & Classification'),
                const SizedBox(height: 12),

                if (isWide)
                  Row(
                    children: [
                      Expanded(child: _areaField()),
                      const SizedBox(width: 16),
                      Expanded(child: _categoryField()),
                    ],
                  )
                else ...[
                  _areaField(),
                  const SizedBox(height: 12),
                  _categoryField(),
                ],

                const SizedBox(height: 24),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    TipChip(icon: Icons.badge_outlined, text: 'Use legal/trade name'),
                    TipChip(icon: Icons.place_outlined, text: 'Full address = smooth delivery'),
                    TipChip(icon: Icons.category_outlined, text: 'Category improves reports'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // --- Fields ---------------------------------------------------------------

  Widget _nameField() {
    return TextFormField(
      controller: name,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Customer Name *',
        hintText: 'Enter full customer name',
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        filled: true,
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name is required' : null,
      onChanged: onNameChanged,
    );
  }

  Widget _addressField() {
    return TextFormField(
      controller: address,
      minLines: 3,
      maxLines: 6,
      textInputAction: TextInputAction.newline,
      decoration: const InputDecoration(
        labelText: 'Address *',
        hintText: 'Enter complete address',
        prefixIcon: Icon(Icons.home_work_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        filled: true,
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
      onChanged: onAddressChanged,
    );
  }

  Widget _areaField() {
    return DropdownButtonFormField<RefItem>(
      value: selectedArea,
      items: areas.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
      decoration: const InputDecoration(
        labelText: 'Area *',
        hintText: 'Select customer area',
        prefixIcon: Icon(Icons.place_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        filled: true,
      ),
      validator: (v) => v == null ? 'Please select an area' : null,
      onChanged: onAreaChanged,
    );
  }

  Widget _categoryField() {
    return DropdownButtonFormField<RefItem>(
      value: selectedCategory,
      items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
      decoration: const InputDecoration(
        labelText: 'Customer Category *',
        hintText: 'Select customer category',
        prefixIcon: Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        filled: true,
      ),
      validator: (v) => v == null ? 'Please select a category' : null,
      onChanged: onCategoryChanged,
    );
  }
}
