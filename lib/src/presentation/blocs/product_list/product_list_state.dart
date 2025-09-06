
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/product_list.dart';

enum ProductListStatus { loading, ready, empty, paginating, failure }

class ProductListState {
  final ProductListStatus status;
  final List<Product> items;
  final String search;
  final String? error;
  final DocumentSnapshot<Map<String, dynamic>>? cursor;
  final bool hasMore;

  const ProductListState({
    this.status = ProductListStatus.loading,
    this.items = const [],
    this.search = '',
    this.error,
    this.cursor,
    this.hasMore = true,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? items,
    String? search,
    String? error,
    DocumentSnapshot<Map<String, dynamic>>? cursor,
    bool? hasMore,
  }) => ProductListState(
    status: status ?? this.status,
    items: items ?? this.items,
    search: search ?? this.search,
    error: error,
    cursor: cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
  );
}
