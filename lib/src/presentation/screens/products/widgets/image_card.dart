
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagesCard extends StatelessWidget {
  final List<XFile> files;
  final ValueChanged<List<XFile>> onPick;
  final ValueChanged<int> onRemove;

  const ImagesCard({required this.files, required this.onPick, required this.onRemove});

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 80);
    if (result.isNotEmpty) onPick(result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Product Images', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (files.isEmpty)
              InkWell(
                onTap: () => _pick(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                    color: cs.surfaceVariant.withOpacity(.4),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 28),
                        SizedBox(height: 8),
                        Text('Add images'),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: files.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1,
                    ),
                    itemBuilder: (_, i) {
                      final f = files[i];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(f.path), fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 4, top: 4,
                            child: InkWell(
                              onTap: () => onRemove(i),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54, borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pick(context),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add more'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}