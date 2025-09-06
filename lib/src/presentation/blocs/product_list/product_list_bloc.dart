import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_query_repository.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductQueryRepository repo;
  ProductListBloc({required this.repo}) : super(const ProductListState()) {
    on<ProductListStarted>(_onStartOrRefresh);
    on<ProductListRefreshed>(_onStartOrRefresh);
    on<ProductListSearchChanged>(_onSearch);
    on<ProductListNextPageRequested>(_onNextPage);
  }

  Future<void> _onStartOrRefresh(ProductListEvent e, Emitter<ProductListState> emit) async {
    emit(state.copyWith(status: ProductListStatus.loading));
    try {
      final page = await repo.firstPage(search: state.search);
      if (page.items.isEmpty) {
        emit(state.copyWith(status: ProductListStatus.empty, items: [], cursor: null, hasMore: false));
      } else {
        emit(state.copyWith(status: ProductListStatus.ready, items: page.items, cursor: page.cursor, hasMore: page.hasMore));
      }
    } catch (_) {
      emit(state.copyWith(status: ProductListStatus.failure, error: 'Failed to load products.'));
    }
  }

  Future<void> _onSearch(ProductListSearchChanged e, Emitter<ProductListState> emit) async {
    emit(state.copyWith(search: e.q));
    add(ProductListStarted());
  }

  Future<void> _onNextPage(ProductListNextPageRequested e, Emitter<ProductListState> emit) async {
    if (!state.hasMore || state.cursor == null || state.status == ProductListStatus.paginating) return;
    emit(state.copyWith(status: ProductListStatus.paginating));
    try {
      final page = await repo.nextPage(cursor: state.cursor!, search: state.search);
      emit(state.copyWith(
        status: ProductListStatus.ready,
        items: [...state.items, ...page.items],
        cursor: page.cursor,
        hasMore: page.hasMore,
      ));
    } catch (_) {
      emit(state.copyWith(status: ProductListStatus.ready)); // keep existing list
    }
  }
}
