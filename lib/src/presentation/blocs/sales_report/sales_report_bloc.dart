import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_test_app/src/presentation/blocs/sales_report/sales_report_event.dart';
import 'package:sales_test_app/src/presentation/blocs/sales_report/sales_report_state.dart';
import '../../../data/repositories/grouped_sales_report_repository.dart';


class SalesReportGroupedBloc extends Bloc<SalesReportGroupedEvent, SalesReportGroupedState> {
  final GroupedSalesReportRepository repo;
  SalesReportGroupedBloc({required this.repo}) : super(SalesReportGroupedState.initial()) {
    on<SRGStarted>(_load);
    on<SRGRefreshed>(_load);
    on<SRGRangeChanged>((e, emit) async {
      emit(state.copyWith(status: SRGStatus.loading, start: e.start, end: e.end, clearError: true));
      await _load(e, emit);
    });
  }

  Future<void> _load(SalesReportGroupedEvent e, Emitter<SalesReportGroupedState> emit) async {
    final start = (e is SRGStarted) ? e.start : state.start;
    final end   = (e is SRGStarted) ? e.end   : state.end;
    try {
      final data = await repo.load(start, end);
      emit(state.copyWith(status: SRGStatus.ready, data: data, start: start, end: end));
    } catch (_) {
      emit(state.copyWith(status: SRGStatus.failure, error: 'Failed to load report'));
    }
  }
}
