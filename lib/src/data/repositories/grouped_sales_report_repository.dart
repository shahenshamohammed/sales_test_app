import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_grouped_report.dart';


abstract class GroupedSalesReportRepository {
  Future<GroupedSalesReport> load(DateTime start, DateTime end);
}

class FirestoreGroupedSalesReportRepository implements GroupedSalesReportRepository {
  final FirebaseFirestore _db;
  final String saleCollection;
  final String productCollection;
  final String productCategoryCollection;

  FirestoreGroupedSalesReportRepository({
    FirebaseFirestore? db,
    this.saleCollection = 'sales',                 // invoices
    this.productCollection = 'product_master',    // products
    this.productCategoryCollection = 'product_category', // categories
  }) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<GroupedSalesReport> load(DateTime start, DateTime end) async {
    // normalize to day bounds
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

    // 1) headers in range
    final headersSnap = await _db.collection(saleCollection)
        .where('date', isGreaterThanOrEqualTo: s)
        .where('date', isLessThanOrEqualTo: e)
        .orderBy('date')
        .get();

    if (headersSnap.docs.isEmpty) {
      return GroupedSalesReport(start: s, end: e, categories: const [], grandTotal: 0);
    }

    // 2) items under each sale
    final itemFutures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (final h in headersSnap.docs) {
      itemFutures.add(_db.collection(saleCollection).doc(h.id).collection('items').get());
    }
    final itemsSnaps = await Future.wait(itemFutures);

    // 3) aggregate qty/amount per productId
    final byProduct = <String, _Agg>{};
    for (final snap in itemsSnaps) {
      for (final d in snap.docs) {
        final m = d.data();
        final productId = (m['productId'] ?? '') as String;
        if (productId.isEmpty) continue;
        final name = (m['name'] ?? '') as String;
        final qty  = (m['qty'] as num?)?.toInt() ?? 0;
        final rate = (m['rate'] as num?)?.toDouble() ?? 0.0; // unit at time of sale
        if (qty <= 0) continue;

        final a = byProduct.putIfAbsent(productId, () => _Agg(nameFallback: name));
        a.qty     += qty;
        a.amount  += qty * rate;
        a.rateSum += rate * qty; // weighted average fallback if catalog price missing
      }
    }

    if (byProduct.isEmpty) {
      return GroupedSalesReport(start: s, end: e, categories: const [], grandTotal: 0);
    }

    // 4) join product master for code/name/categoryId and preferred unit price
    final productIds = byProduct.keys.toList();
    final productDocs = await _fetchDocsByIds(productCollection, productIds);

    final categoryIds = <String>{};
    for (final doc in productDocs) {
      final data = doc.data();
      if (data == null) continue;
      final agg = byProduct[doc.id];
      if (agg == null) continue;

      // prefer catalog name if present
      final prodName = (data['name'] as String?)?.trim();
      if (prodName != null && prodName.isNotEmpty) {
        agg.nameOverride = prodName;
      }

      // code/sku fallback
      final rawCode = (data['code'] ?? data['sku'])?.toString();
      agg.code = _deriveCode(rawCode, doc.id);

      // preferred unit price from catalog if available
      agg.catalogPrice = _parsePrice(data);

      // category id
      final cid = (data['categoryId'] as String?)?.trim();
      agg.categoryId = (cid == null || cid.isEmpty) ? 'uncat' : cid;
      if (cid != null && cid.isNotEmpty) categoryIds.add(cid);
    }

    // 5) resolve categoryId → name
    final catNameById = <String, String>{};
    if (categoryIds.isNotEmpty) {
      final catDocs = await _fetchDocsByIds(productCategoryCollection, categoryIds.toList());
      for (final d in catDocs) {
        final m = d.data();
        if (m == null) continue;
        final name = (m['name'] as String?)?.trim() ?? (m['title'] as String?)?.trim();
        catNameById[d.id] = (name == null || name.isEmpty) ? 'Uncategorized' : name;
      }
    }

    // 6) build rows grouped by categoryId
    final rowsByCategory = <String, List<CategoryRow>>{};
    final subtotalByCategory = <String, double>{};

    byProduct.forEach((pid, a) {
      final cid = a.categoryId ?? 'uncat';
      final name = a.nameOverride ?? a.nameFallback;

      // choose unit price: catalog preferred, else weighted avg from sold items
      final unitPrice = a.catalogPrice ?? (a.qty == 0 ? 0.0 : a.amount / a.qty);

      final row = CategoryRow(
        code: a.code ?? '—',
        name: name,
        qty: a.qty,
        price: unitPrice,
        amount: a.amount, // aggregated from sold items
      );

      rowsByCategory.putIfAbsent(cid, () => []).add(row);
      subtotalByCategory[cid] = (subtotalByCategory[cid] ?? 0) + a.amount;
    });

    // 7) to view model lists
    final categories = <CategoryReport>[];
    double grand = 0;
    rowsByCategory.forEach((cid, rows) {
      rows.sort((a, b) => a.name.compareTo(b.name));
      final subtotal = subtotalByCategory[cid] ?? 0.0;
      grand += subtotal;
      categories.add(CategoryReport(
        categoryId: cid,
        categoryName: catNameById[cid] ?? 'Uncategorized',
        subtotal: subtotal,
        rows: rows,
      ));
    });
    categories.sort((a, b) => b.subtotal.compareTo(a.subtotal));

    return GroupedSalesReport(start: s, end: e, categories: categories, grandTotal: grand);
  }

  // -------- helpers --------

  // batched whereIn (limit ~10)
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _fetchDocsByIds(
      String collection, List<String> ids) async {
    if (ids.isEmpty) return const [];
    final out = <DocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < ids.length; i += 10) {
      final end = (i + 10) > ids.length ? ids.length : (i + 10);
      final chunk = ids.sublist(i, end);
      final snap = await _db.collection(collection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      out.addAll(snap.docs);
    }
    return out;
  }

  // derive catalog code; fallback to first 4 chars of id
  String _deriveCode(String? rawCode, String id) {
    final code = rawCode?.trim();
    if (code != null && code.isNotEmpty) return code.toUpperCase();
    final take = id.length < 4 ? id.length : 4;
    return id.substring(0, take).toUpperCase();
  }

  // read price from product master: try multiple common keys
  double? _parsePrice(Map<String, dynamic> data) {
    final keys = ['salesRate', 'saleRate', 'price', 'unitPrice', 'sellingPrice'];
    for (final k in keys) {
      final v = data[k];
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}

class _Agg {
  final String nameFallback;
  int qty = 0;
  double rateSum = 0;     // for weighted avg if needed
  double amount = 0;      // sum of (qty * rate) across items
  String? code;
  String? nameOverride;   // prefer product master 'name'
  String? categoryId;
  double? catalogPrice;   // prefer this for unit price
  _Agg({required this.nameFallback});
}
