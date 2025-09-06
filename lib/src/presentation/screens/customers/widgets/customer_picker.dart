import 'package:flutter/material.dart';
import '../../../../data/repositories/selectors_repository.dart';

class CustomerPickerSheet extends StatefulWidget {
  const CustomerPickerSheet({super.key});
  @override State<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<CustomerPickerSheet> {
  final repo = SelectorsRepository();
  final search = TextEditingController();
  var items = <CustomerLite>[];
  bool loading = false;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load([String q = '']) async {
    setState(() => loading = true);
    items = await repo.searchCustomers(q);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false, initialChildSize: .85, minChildSize: .5, builder: (_, ctrl) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: search,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search customers'),
                  onChanged: _load,
                ),
              ),
              Expanded(
                child: loading ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                  controller: ctrl,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(items[i].name),
                    onTap: () => Navigator.of(context).pop((items[i].id, items[i].name)),
                  ),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}
