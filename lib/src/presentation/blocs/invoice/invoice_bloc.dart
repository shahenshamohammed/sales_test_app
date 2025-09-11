import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/invoice_form.dart';
import '../../../data/repositories/invoice_repository.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoicesRepository repo;
  InvoiceBloc({required this.repo}) : super(InvoiceState.initial()) {
    on<InvoiceStarted>((e, emit) => emit(InvoiceState.initial()));
    on<InvoiceCustomerSelected>(_onCustomer);
    on<InvoiceDateChanged>((e, emit) => emit(state.copyWith(date: e.date, clearError: true)));
    on<InvoiceItemAdded>(_onAddItem);
    on<InvoiceItemUpdated>((e, emit) {
      final list = [...state.items]..[e.index] = e.item;
      emit(state.copyWith(items: list));
    });
    on<InvoiceItemRemoved>((e, emit) {
      final list = [...state.items]..removeAt(e.index);
      emit(state.copyWith(items: list));
    });
    on<InvoiceSubmitted>(_onSubmit);
  }

  void _onCustomer(InvoiceCustomerSelected e, Emitter<InvoiceState> emit) {
    emit(state.copyWith(
      customerId: e.customerId,
      customerName: e.customerName,
      customerAddress: e.customerAddress,
      clearError: true,
    ));
  }

  void _onAddItem(InvoiceItemAdded e, Emitter<InvoiceState> emit) {
    final idx = state.items.indexWhere((it) => it.productId == e.item.productId);
    final list = [...state.items];
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(qty: list[idx].qty + e.item.qty, rate: e.item.rate);
    } else {
      list.add(e.item);
    }
    emit(state.copyWith(items: list));
  }

  Future<void> _onSubmit(InvoiceSubmitted e, Emitter<InvoiceState> emit) async {
    if (!state.canSubmit) {
      emit(state.copyWith(status: InvoiceStatus.failure, error: 'Pick a customer and add at least one product.'));
      return;
    }
    emit(state.copyWith(status: InvoiceStatus.submitting, clearError: true));
    try {
      final draft = InvoiceDraft(
        invoiceNo: state.invoiceNo,
        customerId: state.customerId!,
        customerName: state.customerName ?? '',
        customerAddress: state.customerAddress,
        date: state.date,
        items: state.items,
      );

      await repo.create(draft);
      emit(state.copyWith(status: InvoiceStatus.success));
    } catch (_) {
      emit(state.copyWith(status: InvoiceStatus.failure, error: 'Could not save invoice.'));
    }
  }
}
