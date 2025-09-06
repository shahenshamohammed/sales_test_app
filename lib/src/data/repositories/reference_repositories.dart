import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ref_item_int.dart';

abstract class ReferenceRepository {
  Future<List<RefItem>> getAreas();
  Future<List<RefItem>> getCustomerCategories();
}

class FirestoreReferenceRepository implements ReferenceRepository {
  final FirebaseFirestore _db;
  FirestoreReferenceRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<List<RefItem>> getAreas() async {
    print("============================$_db");
    final q = await _db.collection('customer_area').orderBy('name').get();
    return q.docs.map((d) => RefItem(id: d.id, name: (d['name'] as String))).toList();
  }

  @override
  Future<List<RefItem>> getCustomerCategories() async {
    final q = await _db.collection('customer category').orderBy('Name').get();
    return q.docs.map((d) => RefItem(id: d.id, name: (d['Name'] as String))).toList();
  }
}
