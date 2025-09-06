import '../../../data/models/sales_grouped_report.dart';

enum SRGStatus { loading, ready, failure }

class SalesReportGroupedState {
  final SRGStatus status;
  final String? error;
  final DateTime start;
  final DateTime end;
  final GroupedSalesReport? data;

  const SalesReportGroupedState({
    required this.status,
    this.error,
    required this.start,
    required this.end,
    this.data,
  });

  SalesReportGroupedState copyWith({
    SRGStatus? status,
    String? error,
    DateTime? start,
    DateTime? end,
    GroupedSalesReport? data,
    bool clearError = false,
  }) => SalesReportGroupedState(
    status: status ?? this.status,
    error: clearError ? null : (error ?? this.error),
    start: start ?? this.start,
    end: end ?? this.end,
    data: data ?? this.data,
  );

  factory SalesReportGroupedState.initial() {
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, 1);
    final e = DateTime(now.year, now.month + 1, 0);
    return SalesReportGroupedState(status: SRGStatus.loading, start: s, end: e);
  }
}
