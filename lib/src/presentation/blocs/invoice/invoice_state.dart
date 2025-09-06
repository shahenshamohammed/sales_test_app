import '../../../data/models/invoice_form.dart';


enum InvoiceStatus { ready, submitting, success, failure }

class InvoiceState {
  final InvoiceStatus status;
  final String? error;

  final String invoiceNo;
  final String? customerId;
  final String? customerName;
  final String? customerAddress;
  final DateTime date;
  final List<LineItem> items;

  const InvoiceState({
    this.status = InvoiceStatus.ready,
    this.error,
    required this.invoiceNo,
    this.customerId,
    this.customerName,
    this.customerAddress,
    required this.date,
    this.items = const [],
  });

  double get total => items.fold(0.0, (t, i) => t + i.lineTotal);
  int get totalItems => items.fold(0, (t, i) => t + i.qty.round());
  bool get canSubmit => customerId != null && items.isNotEmpty;

  InvoiceState copyWith({
    InvoiceStatus? status,
    String? error,
    String? invoiceNo,
    String? customerId,
    String? customerName,
    String? customerAddress,
    DateTime? date,
    List<LineItem>? items,
    bool clearError = false,
  }) => InvoiceState(
    status: status ?? this.status,
    error: clearError ? null : (error ?? this.error),
    invoiceNo: invoiceNo ?? this.invoiceNo,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    customerAddress: customerAddress ?? this.customerAddress,
    date: date ?? this.date,
    items: items ?? this.items,
  );

  factory InvoiceState.initial() => InvoiceState(
    invoiceNo: _genInvoiceNo(),
    date: DateTime.now(),
  );

  static String _genInvoiceNo() {
    final n = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'INV-${n.toString().padLeft(6, '0')}';
  }
}
