class CategoryRow {
  final String code;
  final String name;     // was description
  final int qty;
  final double price;    // unit price (from product_master.salesRate if present, else weighted avg)
  final double amount;   // aggregated line totals

  const CategoryRow({
    required this.code,
    required this.name,
    required this.qty,
    required this.price,
    required this.amount,
  });
}

class CategoryReport {
  final String categoryId;
  final String categoryName;
  final double subtotal; // sum(amount) for rows
  final List<CategoryRow> rows;

  const CategoryReport({
    required this.categoryId,
    required this.categoryName,
    required this.subtotal,
    required this.rows,
  });
}

class GroupedSalesReport {
  final DateTime start;
  final DateTime end;
  final List<CategoryReport> categories;
  final double grandTotal;

  const GroupedSalesReport({
    required this.start,
    required this.end,
    required this.categories,
    required this.grandTotal,
  });
}
