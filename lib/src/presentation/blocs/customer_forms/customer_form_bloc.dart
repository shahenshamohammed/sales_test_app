import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/customer_input_int.dart';
import '../../../data/repositories/reference_repositories.dart';
import 'customer_form_event.dart';
import 'customer_form_state.dart';

import '../../../data/repositories/customer_repository.dart';

class CustomerFormBloc extends Bloc<CustomerFormEvent, CustomerFormState> {
  final ReferenceRepository refs;
  final CustomerRepository repo;

  CustomerFormBloc({required this.refs, required this.repo})
      : super(CustomerFormState.initial()) {
    on<CustomerFormStarted>(_onStarted);
    on<CustomerNameChanged>((e, emit) => emit(state.copyWith(name: e.name, clearError: true)));
    on<CustomerAddressChanged>((e, emit) => emit(state.copyWith(address: e.address, clearError: true)));
    on<CustomerAreaChanged>((e, emit) => emit(state.copyWith(selectedArea: e.area, clearError: true)));
    on<CustomerCategoryChanged>((e, emit) => emit(state.copyWith(selectedCategory: e.category, clearError: true)));
    on<CustomerFormSubmitted>(_onSubmit);
  }

  Future<void> _onStarted(CustomerFormStarted e, Emitter<CustomerFormState> emit) async {
    emit(state.copyWith(status: CustomerFormStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        refs.getAreas(),
        refs.getCustomerCategories(),
      ]);
      emit(state.copyWith(
        status: CustomerFormStatus.ready,
        areas: results[0],
        categories: results[1],
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CustomerFormStatus.failure,
        error: 'Failed to load reference data.',
      ));
    }
  }

  Future<void> _onSubmit(CustomerFormSubmitted e, Emitter<CustomerFormState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(status: CustomerFormStatus.failure, error: 'Please complete all required fields.'));
      return;
    }
    emit(state.copyWith(status: CustomerFormStatus.submitting, clearError: true));
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final input = CustomerInput(
        name: state.name,
        address: state.address,
        areaId: state.selectedArea!.id,
        categoryId: state.selectedCategory!.id,
        areaName: state.selectedArea!.name,
        categoryName: state.selectedCategory!.name,
        createdByUid: uid,
      );
      await repo.createCustomer(input);
      emit(state.copyWith(status: CustomerFormStatus.success));
    } catch (_) {
      emit(state.copyWith(status: CustomerFormStatus.failure, error: 'Could not save. Please try again.'));
    }
  }
}
