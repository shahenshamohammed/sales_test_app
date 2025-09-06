import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOption {
  final String id;
  final String name;
  final String address;
  final String area;
  const CustomerOption({required this.id, required this.name, this.address = '', this.area = ''});
}

class CustomerDropdownState {
  final bool loading;
  final String? error;
  final List<CustomerOption> items;
  const CustomerDropdownState({this.loading = true, this.error, this.items = const []});

  CustomerDropdownState copyWith({bool? loading, String? error, List<CustomerOption>? items}) =>
      CustomerDropdownState(loading: loading ?? this.loading, error: error, items: items ?? this.items);
}

class CustomerDropdownCubit extends Cubit<CustomerDropdownState> {
  final FirebaseFirestore _db;
  final String collectionPath; // 'customers' or your actual name
  final int limit;
  CustomerDropdownCubit({FirebaseFirestore? db, this.collectionPath = 'customer master', this.limit = 300})
      : _db = db ?? FirebaseFirestore.instance, super(const CustomerDropdownState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final snap = await _db.collection(collectionPath).orderBy('name').limit(limit).get();
      final items = snap.docs.map((d) {
        final m = d.data();
        return CustomerOption(
          id: d.id,
          name: (m['name'] ?? '') as String,
          address: (m['address'] ?? '') as String,
          area: (m['areaName'] ?? m['area'] ?? '') as String,
        );
      }).toList();
      emit(state.copyWith(loading: false, items: items));
    } on FirebaseException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? 'Failed to load customers'));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Failed to load customers'));
    }
  }
}
