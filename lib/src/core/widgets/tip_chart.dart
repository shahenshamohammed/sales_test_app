// lib/src/presentation/screens/customers/add/widgets/tip_chip.dart
import 'package:flutter/material.dart';

class TipChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const TipChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
