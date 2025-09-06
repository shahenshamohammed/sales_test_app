import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CustomerLite { final String id; final String name; CustomerLite(this.id, this.name); }
class ProductLite  { final String id; final String name; final String? coverUrl; final double rate;
ProductLite({required this.id, required this.name, required this.rate, this.coverUrl}); }

class SelectorsRepository {
  final FirebaseFirestore _db;
  SelectorsRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<List<CustomerLite>> searchCustomers(String query) async {
    print("----------------$query");
    try {
      final q = query.trim().toLowerCase();
      var col = _db.collection('customer master'); // ← make sure this matches your real collection!
      // If your collection name really has a space ("customer master"), keep it exactly the same.
      // Best practice is no spaces: use "customers".

      Query<Map<String, dynamic>> queryRef = col.orderBy('nameLower');

      // If you only want prefix search when user typed something:
      if (q.isNotEmpty) {
        queryRef = queryRef.startAt([q]).endAt(['$q\uf8ff']);
      }

      final snap = await queryRef.limit(20).get();

      debugPrint('customers count: ${snap.size}');
      for (final d in snap.docs) {
        debugPrint('customer -> id:${d.id} name:${d.data()['name']}');
      }

      return snap.docs.map((d) => CustomerLite(
        d.id,
        (d.data()['name'] as String?) ?? '',
      )).toList();
    } on FirebaseException catch (e) {
      debugPrint('searchCustomers error: ${e.code} ${e.message}');
      rethrow;
    }
  }


  Future<List<ProductLite>> searchProducts(String query) async {
    final q = query.trim().toLowerCase();
    final snap = await _db.collection('product_master')
        .orderBy('nameLower')
        .startAt([q]).endAt(['$q\uf8ff'])
        .limit(20).get();
    return snap.docs.map((d) {
      final m = d.data();
      return ProductLite(
        id: d.id,
        name: m['name'] as String? ?? '',
        rate: (m['salesRate'] as num?)?.toDouble() ?? 0,
        coverUrl: m['coverUrl'] as String?,
      );
    }).toList();
  }
}
