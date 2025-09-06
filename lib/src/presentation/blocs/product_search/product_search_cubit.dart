import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPick {
  final String id;
  final String name;
  final double rate;
  final String? coverUrl;
  ProductPick({required this.id, required this.name, required this.rate, this.coverUrl});
}

class ProductSearchState {
  final bool loading;
  final String? error;
  final List<ProductPick> items;
  final String query;
  const ProductSearchState({this.loading = true, this.error, this.items = const [], this.query = ''});

  ProductSearchState copyWith({bool? loading, String? error, List<ProductPick>? items, String? query}) =>
      ProductSearchState(loading: loading ?? this.loading, error: error, items: items ?? this.items, query: query ?? this.query);
}

class ProductSearchCubit extends Cubit<ProductSearchState> {
  final FirebaseFirestore _db;
  final String collectionPath; // 'product_master'
  Timer? _debounce;

  ProductSearchCubit({FirebaseFirestore? db, this.collectionPath = 'product_master'})
      : _db = db ?? FirebaseFirestore.instance,
        super(const ProductSearchState());

  void setQuery(String q) {
    _debounce?.cancel();
    emit(state.copyWith(query: q));
    _debounce = Timer(const Duration(milliseconds: 250), () => _load(q));
  }

  Future<void> loadInitial() => _load('');

  Future<void> _load(String query) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final q = query.trim().toLowerCase();
      Query<Map<String, dynamic>> ref = _db.collection(collectionPath).orderBy('nameLower');
      if (q.isNotEmpty) {
        ref = ref.startAt([q]).endAt(['$q\uf8ff']);
      }
      final snap = await ref.limit(40).get();
      final items = snap.docs.map((d) {
        final m = d.data();
        return ProductPick(
          id: d.id,
          name: (m['name'] ?? '') as String,
          rate: (m['salesRate'] as num?)?.toDouble() ?? 0,
          coverUrl: m['coverUrl'] as String?,
        );
      }).toList();
      emit(state.copyWith(loading: false, items: items));
    } on FirebaseException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? 'Failed to load products'));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Failed to load products'));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
