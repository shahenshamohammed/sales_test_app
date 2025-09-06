
import 'package:flutter/material.dart';

import '../../../../data/models/product_input.dart';

class BasicInfoCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final ValueChanged<String> onNameChanged;

  final List<RefItem> categories;
  final RefItem? selectedCategory;
  final ValueChanged<RefItem?> onCategoryChanged;

  final List<RefItem> brands;
  final RefItem? selectedBrand;
  final ValueChanged<RefItem?> onBrandChanged;

  const BasicInfoCard({
    required this.formKey,
    required this.nameCtrl,
    required this.onNameChanged,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.brands,
    required this.selectedBrand,
    required this.onBrandChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Basic Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  filled: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                onChanged: onNameChanged,
              ),
              const SizedBox(height: 12),
              isWide
                  ? Row(
                children: [
                  Expanded(child: _categoryField()),
                  const SizedBox(width: 12),
                  Expanded(child: _brandField()),
                ],
              )
                  : Column(
                children: [
                  _categoryField(),
                  const SizedBox(height: 12),
                  _brandField(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryField() => DropdownButtonFormField<RefItem>(
    value: selectedCategory,
    items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
    onChanged: onCategoryChanged,
    validator: (v) => v == null ? 'Select category' : null,
    decoration: const InputDecoration(
      labelText: 'Category *',
      prefixIcon: Icon(Icons.category_outlined),
      filled: true,
    ),
  );

  Widget _brandField() => DropdownButtonFormField<RefItem>(
    value: selectedBrand,
    items: brands.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
    onChanged: onBrandChanged,
    validator: (v) => v == null ? 'Select brand' : null,
    decoration: const InputDecoration(
      labelText: 'Brand *',
      prefixIcon: Icon(Icons.sell_outlined),
      filled: true,
    ),
  );
}