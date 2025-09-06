import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/customer_dropdown/customer_dropdown_cubit.dart';

typedef CustomerSelected = void Function(CustomerOption option);

class CustomerDropdownField extends StatelessWidget {
  final String? selectedCustomerId;
  final CustomerSelected onSelected;

  const CustomerDropdownField({
    super.key,
    required this.selectedCustomerId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDropdownCubit, CustomerDropdownState>(
      builder: (context, state) {
        if (state.loading) {
          return const InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select Customer *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
              filled: true,
            ),
            child: SizedBox(height: 18, child: LinearProgressIndicator(minHeight: 4)),
          );
        }

        if (state.error != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Customer *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                ),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () => context.read<CustomerDropdownCubit>().load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          );
        }

        final items = state.items;
        if (items.isEmpty) {
          return const InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select Customer *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
              filled: true,
            ),
            child: Text('No customers found'),
          );
        }

        // Ensure current value is valid to keep the menu opening properly.
        final value = (selectedCustomerId != null &&
            items.any((e) => e.id == selectedCustomerId))
            ? selectedCustomerId
            : null;

        // Compact single-line label for the CLOSED field.
        List<Widget> _selectedBuilders(BuildContext ctx) {
          final style = Theme.of(ctx).textTheme.bodyMedium;
          return items.map((c) {
            final label = _compactSelectedLabel(c);
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            );
          }).toList();
        }

        return DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          menuMaxHeight: 320,
          // When closed, show compact "Name · Area" one-liner.
          selectedItemBuilder: _selectedBuilders,
          items: items.map((c) {
            return DropdownMenuItem<String>(
              value: c.id,
              // Row + Expanded ensures long text ellipsizes instead of overflowing.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (c.area.isNotEmpty)
                          Text(
                            c.area, // keep just area to reduce width; add address if you really need it
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (id) {
            if (id == null) return;
            final opt = items.firstWhere((e) => e.id == id);
            onSelected(opt);
          },
          decoration: const InputDecoration(
            labelText: 'Select Customer *',
            hintText: 'Choose customer',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_search_outlined),
            filled: true,
          ),
          validator: (v) => v == null ? 'Please select a customer' : null,
        );
      },
    );
  }

  String _compactSelectedLabel(CustomerOption c) {
    final parts = <String>[];
    if (c.name.trim().isNotEmpty) parts.add(c.name.trim());
    if (c.area.trim().isNotEmpty) parts.add(c.area.trim());
    return parts.join(' · ');
  }
}
