import 'package:flutter/material.dart';

class AddCustomerBanner extends StatelessWidget {
  final VoidCallback onAdd;
  const AddCustomerBanner({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [cs.primary, cs.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: cs.onPrimary.withOpacity(.15),
              child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Add New Customer',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Create a new customer in seconds',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
