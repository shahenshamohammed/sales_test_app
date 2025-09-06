class LineItem {
  final String productId;
  final String name;
  final double rate;
  final double qty;
  final String? coverUrl;

  const LineItem({
    required this.productId,
    required this.name,
    required this.rate,
    required this.qty,
    this.coverUrl,
  });

  double get lineTotal => rate * qty;

  LineItem copyWith({String? productId, String? name, double? rate, double? qty, String? coverUrl}) {
    return LineItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      qty: qty ?? this.qty,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'rate': rate,
    'qty': qty,
    'coverUrl': coverUrl,
  };
}

class InvoiceDraft {
  final String invoiceNo;
  final String customerId;
  final String customerName;
  final String? customerAddress;
  final DateTime date;
  final List<LineItem> items;

  const InvoiceDraft({
    required this.invoiceNo,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.items,
    this.customerAddress,
  });

  double get total => items.fold<double>(0, (t, i) => t + i.lineTotal);

  Map<String, dynamic> toHeaderMap() => {
    'invoiceNo': invoiceNo,
    'customerId': customerId,
    'customerName': customerName,
    if (customerAddress != null) 'customerAddress': customerAddress,
    'date': date,
    'total': total,
    'createdAt': DateTime.now(),
  };
}
