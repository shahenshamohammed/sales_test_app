class SalesReportMetrics {
  final DateTime start;
  final DateTime end;
  final double totalRevenue;
  final int totalInvoices;
  final int totalItems;
  final double avgOrderValue;
  final List<TopProduct> topProducts;

  const SalesReportMetrics({
    required this.start,
    required this.end,
    required this.totalRevenue,
    required this.totalInvoices,
    required this.totalItems,
    required this.avgOrderValue,
    required this.topProducts,
  });

  factory SalesReportMetrics.empty(DateTime start, DateTime end) => SalesReportMetrics(
    start: start,
    end: end,
    totalRevenue: 0,
    totalInvoices: 0,
    totalItems: 0,
    avgOrderValue: 0,
    topProducts: const [],
  );
}

class TopProduct {
  final String productId;
  final String name;
  final int qty;         // summed qty
  final double amount;   // summed qty * rate
  final String? coverUrl;

  const TopProduct({required this.productId, required this.name, required this.qty, required this.amount, this.coverUrl});
}
