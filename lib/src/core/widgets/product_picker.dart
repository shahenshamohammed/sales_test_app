import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_pick.dart';

class ProductListSheet extends StatelessWidget {
  final String collectionPath; // e.g. 'product_master'
  const ProductListSheet({super.key, this.collectionPath = 'product_master'});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 35, 16, 24),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: db.collection(collectionPath).orderBy('name').limit(100).get(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('No products'));
            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final d = docs[i];
                final m = d.data();
                final p = ProductPick(
                  id: d.id,
                  name: (m['name'] ?? '') as String,
                  rate: (m['salesRate'] as num?)?.toDouble() ?? 0,
                  coverUrl: m['coverUrl'] as String?,
                );
                return ListTile(
                  leading: SizedBox(
                    width: 44, height: 44,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (p.coverUrl == null || p.coverUrl!.isEmpty)
                          ? Container(color: Colors.black12, child: const Icon(Icons.inventory_2_outlined))
                          : CachedNetworkImage(imageUrl: p.coverUrl!, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Unit: ${p.rate.toStringAsFixed(2)}'),
                  onTap: () => Navigator.of(context).pop(p),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
