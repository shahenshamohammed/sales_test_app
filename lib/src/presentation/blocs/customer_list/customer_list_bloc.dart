import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/repositories/customer_list_repository.dart';
import 'customer_list_event.dart';
import 'customer_list_state.dart';
import '../../../data/repositories/customer_repository.dart';

class CustomerListBloc extends Bloc<CustomerListEvent, CustomerListState> {
  final FirestoreCustomerListRepository  repo;
  DocumentSnapshot? _lastDoc;

  CustomerListBloc({required this.repo}) : super(CustomerListState.initial()) {
    on<CustomerListStarted>(_onLoadFirst);
    on<CustomerListRefreshed>(_onRefresh);
    on<CustomerListNextPageRequested>(_onNextPage);
    on<CustomerListAreaFilterChanged>(_onAreaChanged);
    on<CustomerListCategoryFilterChanged>(_onCategoryChanged);
    on<CustomerListSearchChanged>(_onSearchChanged);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) _lastDoc = null;

    final isFirst = _lastDoc == null;
    emit(state.copyWith(
      status: isFirst ? CustomerListStatus.loading : CustomerListStatus.paginating,
      clearError: true,
    ));

    try {
      final page = await repo.fetchPage(CustomerListQuery(
        areaId: state.areaId,
        categoryId: state.categoryId,
        search: state.search,
        limit: 20,
        startAfter: _lastDoc,
      ));

      _lastDoc = page.lastDoc;
      final items = isFirst ? page.items : [...state.items, ...page.items];

      emit(items.isEmpty
          ? state.copyWith(status: CustomerListStatus.empty, items: items, hasMore: page.hasMore)
          : state.copyWith(status: CustomerListStatus.ready, items: items, hasMore: page.hasMore));
    } catch (e) {
      emit(state.copyWith(status: CustomerListStatus.error, error: 'Failed to load customers.'));
    }
  }

  Future<void> _onLoadFirst(CustomerListStarted e, Emitter<CustomerListState> emit) async {
    await _load(reset: true);
  }

  Future<void> _onRefresh(CustomerListRefreshed e, Emitter<CustomerListState> emit) async {
    emit(state.copyWith(status: CustomerListStatus.refreshing));
    await _load(reset: true);
  }

  Future<void> _onNextPage(CustomerListNextPageRequested e, Emitter<CustomerListState> emit) async {
    if (!state.hasMore || state.status == CustomerListStatus.paginating) return;
    await _load(reset: false);
  }

  Future<void> _onAreaChanged(CustomerListAreaFilterChanged e, Emitter<CustomerListState> emit) async {
    emit(state.copyWith(areaId: e.areaId));
    await _load(reset: true);
  }

  Future<void> _onCategoryChanged(CustomerListCategoryFilterChanged e, Emitter<CustomerListState> emit) async {
    emit(state.copyWith(categoryId: e.categoryId));
    await _load(reset: true);
  }

  Future<void> _onSearchChanged(CustomerListSearchChanged e, Emitter<CustomerListState> emit) async {
    emit(state.copyWith(search: e.text));
    await _load(reset: true);
  }
}
