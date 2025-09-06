import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sales_test_app/src/presentation/screens/salesreport/widgets/category_table.dart';
import 'package:sales_test_app/src/presentation/screens/salesreport/widgets/grand_total_bar.dart';
import 'package:sales_test_app/src/presentation/screens/salesreport/widgets/header_strip.dart';


import '../../../data/models/sales_grouped_report.dart';
import '../../../data/repositories/grouped_sales_report_repository.dart';
import '../../blocs/sales_report/sales_report_bloc.dart';
import '../../blocs/sales_report/sales_report_event.dart';
import '../../blocs/sales_report/sales_report_state.dart';

class SalesReportGroupedPage extends StatelessWidget {
  const SalesReportGroupedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end   = DateTime(now.year, now.month + 1, 0);

    return BlocProvider(
      create: (_) => SalesReportGroupedBloc(
        repo: FirestoreGroupedSalesReportRepository(),
      )..add(SRGStarted(start, end)),
      child: const _ReportScaffold(),
    );
  }
}

class _ReportScaffold extends StatelessWidget {
  const _ReportScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesReportGroupedBloc, SalesReportGroupedState>(
      listener: (ctx, s) {
        if (s.status == SRGStatus.failure && s.error != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.error!)));
        }
      },
      builder: (context, state) {
        final loading = state.status == SRGStatus.loading;
        final data = state.data;
        final df = DateFormat('yyyy-MM-dd');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sales Report'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => context.read<SalesReportGroupedBloc>().add(SRGRefreshed()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          // Pin grand total
          bottomNavigationBar: (data == null)
              ? null
              : GrandTotalBar(total: data.grandTotal),
          body: loading && data == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () async =>
                context.read<SalesReportGroupedBloc>().add(SRGRefreshed()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96), // room for pinned bar
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: math.min(900, MediaQuery.of(context).size.width)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeaderStrip(
                        title: 'Sales Report',
                        subtitle: 'From ${df.format(state.start)} to ${df.format(state.end)}',
                        onPickRange: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020, 1, 1),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            initialDateRange: DateTimeRange(start: state.start, end: state.end),
                          );
                          if (picked != null) {
                            context.read<SalesReportGroupedBloc>()
                                .add(SRGRangeChanged(picked.start, picked.end));
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      if (data == null || data.categories.isEmpty)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: Text('No sales in this range')),
                          ),
                        )
                      else ...[
                        for (final cat in data.categories) ...[
                          CategoryTable(category: cat),
                          const SizedBox(height: 10),
                        ],
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}





