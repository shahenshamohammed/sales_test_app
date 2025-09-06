import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_list.dart';

class ProductPage {
  final List<Product> items;
  final DocumentSnapshot<Map<String, dynamic>>? cursor;
  final bool hasMore;
  ProductPage({required this.items, required this.cursor, required this.hasMore});
}

abstract class ProductQueryRepository {
  Future<ProductPage> firstPage({int limit, String? search});
  Future<ProductPage> nextPage({required DocumentSnapshot<Map<String, dynamic>> cursor, int limit, String? search});
}

class FirestoreProductQueryRepository implements ProductQueryRepository {
  final FirebaseFirestore _db;
  FirestoreProductQueryRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Query<Map<String, dynamic>> _baseQuery(String? search) {
    final col = _db.collection('product_master').withConverter(
      fromFirestore: (s, _) => s.data()!,
      toFirestore: (m, _) => m,
    );
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      // nameLower field should exist on product docs
      return col.orderBy('nameLower').startAt([q]).endAt(['$q\uf8ff']);
    }
    return col.orderBy('nameLower');
  }

  @override
  Future<ProductPage> firstPage({int limit = 20, String? search}) async {
    final snap = await _baseQuery(search).limit(limit).get();
    final items = snap.docs.map((d) => Product.fromDoc(d)).toList();
    final cursor = snap.docs.isEmpty ? null : snap.docs.last;
    return ProductPage(items: items, cursor: cursor, hasMore: snap.docs.length == limit);
  }

  @override
  Future<ProductPage> nextPage({required DocumentSnapshot<Map<String, dynamic>> cursor, int limit = 20, String? search}) async {
    final snap = await _baseQuery(search).startAfterDocument(cursor).limit(limit).get();
    final items = snap.docs.map((d) => Product.fromDoc(d)).toList();
    final nextCursor = snap.docs.isEmpty ? null : snap.docs.last;
    return ProductPage(items: items, cursor: nextCursor, hasMore: snap.docs.length == limit);
  }
}
