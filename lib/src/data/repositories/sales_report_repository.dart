import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_report.dart';


abstract class SalesReportRepository {
  Future<SalesReportMetrics> load(DateTime start, DateTime end);
}

class FirestoreSalesReportRepository implements SalesReportRepository {
  final FirebaseFirestore _db;
  final String saleCollection;
  FirestoreSalesReportRepository({FirebaseFirestore? db, this.saleCollection = 'sales'})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<SalesReportMetrics> load(DateTime start, DateTime end) async {
    // Normalize bounds (inclusive day range)
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

    // 1) Query sale headers in range
    final headersSnap = await _db.collection(saleCollection)
        .where('date', isGreaterThanOrEqualTo: s)
        .where('date', isLessThanOrEqualTo: e)
        .orderBy('date')
        .get();

    double revenue = 0;
    int invoices = headersSnap.docs.length;

    // collect item fetches to aggregate top products & item counts
    final itemFetches = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (final d in headersSnap.docs) {
      final m = d.data();
      // header totals (more reliable than summing items if discount/tax later)
      final t = (m['total'] as num?)?.toDouble() ?? 0.0;
      revenue += t;
      itemFetches.add(_db.collection(saleCollection).doc(d.id).collection('items').get());
    }

    int totalItems = 0;
    final byProduct = <String, TopProduct>{};

    final itemsSnaps = await Future.wait(itemFetches);
    for (final snap in itemsSnaps) {
      for (final it in snap.docs) {
        final m = it.data();
        final pid = (m['productId'] ?? it.id) as String;
        final name = (m['name'] ?? '') as String;
        final rate = (m['rate'] as num?)?.toDouble() ?? 0.0;
        final qty  = (m['qty'] as num?)?.toInt() ?? 0;
        final cover = m['coverUrl'] as String?;
        totalItems += qty;

        final amount = rate * qty;
        final prev = byProduct[pid];
        if (prev == null) {
          byProduct[pid] = TopProduct(productId: pid, name: name, qty: qty, amount: amount, coverUrl: cover);
        } else {
          byProduct[pid] = TopProduct(
            productId: pid,
            name: prev.name,
            qty: prev.qty + qty,
            amount: prev.amount + amount,
            coverUrl: prev.coverUrl ?? cover,
          );
        }
      }
    }

    final top = byProduct.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final aov = invoices == 0 ? 0.0 : revenue / invoices;

    return SalesReportMetrics(
      start: s,
      end: e,
      totalRevenue: revenue,
      totalInvoices: invoices,
      totalItems: totalItems,
      avgOrderValue: aov,
      topProducts: top.take(10).toList(),
    );
  }
}
