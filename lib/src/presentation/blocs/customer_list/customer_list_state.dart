
import '../../../data/models/customers.dart';

enum CustomerListStatus { initial, loading, ready, refreshing, paginating, empty, error }

class CustomerListState {
  final CustomerListStatus status;
  final String? error;

  final List<Customer> items;
  final bool hasMore;

  final String? areaId;
  final String? categoryId;
  final String? search;

  const CustomerListState({
    this.status = CustomerListStatus.initial,
    this.error,
    this.items = const [],
    this.hasMore = true,
    this.areaId,
    this.categoryId,
    this.search,
  });

  CustomerListState copyWith({
    CustomerListStatus? status,
    String? error,
    List<Customer>? items,
    bool? hasMore,
    String? areaId,
    String? categoryId,
    String? search,
    bool clearError = false,
  }) {
    return CustomerListState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      areaId: areaId ?? this.areaId,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
    );
  }

  factory CustomerListState.initial() => const CustomerListState();
}
