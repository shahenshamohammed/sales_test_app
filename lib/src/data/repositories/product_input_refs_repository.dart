import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ref_item_int.dart';


abstract class ProductRefsRepository {
  Future<List<RefItem>> getCategories();
  Future<List<RefItem>> getBrands();
}

class FirestoreProductRefsRepository implements ProductRefsRepository {
  final FirebaseFirestore _db;
  FirestoreProductRefsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<List<RefItem>> getCategories() async {
    final q = await _db.collection('productCategories').orderBy('name').get();
    return q.docs.map((d) => RefItem(id: d.id, name: d['name'] as String)).toList();
  }

  @override
  Future<List<RefItem>> getBrands() async {
    final q = await _db.collection('brands').orderBy('name').get();
    return q.docs.map((d) => RefItem(id: d.id, name: d['name'] as String)).toList();
  }
}
