import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customers.dart';

class CustomerPage {
  final List<Customer> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
  const CustomerPage({required this.items, required this.lastDoc, required this.hasMore});
}

class CustomerListQuery {
  final String? areaId;
  final String? categoryId;
  final String? search; // optional (prefix on nameLower)
  final int limit;
  final DocumentSnapshot? startAfter;

  const CustomerListQuery({
    this.areaId,
    this.categoryId,
    this.search,
    this.limit = 20,
    this.startAfter,
  });
}

class FirestoreCustomerListRepository {
  final FirebaseFirestore _db;
  FirestoreCustomerListRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<CustomerPage> fetchPage(CustomerListQuery q) async {
    // Base
    Query<Map<String, dynamic>> query = _db.collection('customer master');

    // Filters
    if (q.areaId != null && q.areaId!.isNotEmpty) {
      query = query.where('areaId', isEqualTo: q.areaId);
    }
    if (q.categoryId != null && q.categoryId!.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: q.categoryId);
    }

    // Search (prefix on nameLower). Make sure you store nameLower at write time.
    if (q.search != null && q.search!.trim().isNotEmpty) {
      final s = q.search!.trim().toLowerCase();
      query = query.orderBy('nameLower').startAt([s]).endAt(['$s\uf8ff']);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    if (q.startAfter != null) {
      query = query.startAfterDocument(q.startAfter!);
    }

    query = query.limit(q.limit);

    final snap = await query.get();
    final items = snap.docs.map((d) => Customer.fromDoc(d)).toList();
    final last = snap.docs.isEmpty ? null : snap.docs.last;
    return CustomerPage(items: items, lastDoc: last, hasMore: snap.docs.length >= q.limit);
  }
}
