import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sales_test_app/src/presentation/screens/Invoice/widgets/header_card.dart';
import 'package:sales_test_app/src/presentation/screens/Invoice/widgets/line_tile.dart';
import 'package:sales_test_app/src/presentation/screens/Invoice/widgets/totalbar.dart';


import '../customers/widgets/customer_drop_down_field.dart';
import '../../../core/widgets/product_picker.dart';
import '../../../data/models/invoice_form.dart';
import '../../../data/models/product_pick.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../blocs/customer_dropdown/customer_dropdown_cubit.dart';
import '../../blocs/invoice/invoice_bloc.dart';
import '../../blocs/invoice/invoice_event.dart';
import '../../blocs/invoice/invoice_state.dart';

class InvoiceCreatePage extends StatelessWidget {
  const InvoiceCreatePage({super.key});

  static const String kCustomersCollection = 'customer master';     // adjust if different
  static const String kProductsCollection  = 'product_master';// adjust if different

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => InvoiceBloc(repo: FirestoreInvoicesRepository())..add(InvoiceStarted())),
        // Provide once at page-level so dropdown overlay works reliably
        BlocProvider(create: (_) => CustomerDropdownCubit(collectionPath: kCustomersCollection)..load()),
      ],
      child: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (ctx, s) {
          if (s.status == InvoiceStatus.failure && s.error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.error!)));
          }
          if (s.status == InvoiceStatus.success) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Invoice saved ✅')));
            Navigator.of(ctx).maybePop();
          }
        },
        builder: (context, state) {
          final saving = state.status == InvoiceStatus.submitting;

          return Scaffold(
            appBar: AppBar(title: const Text('Create Invoice')),
            bottomNavigationBar: TotalsBar(
              totalItems: state.totalItems,
              total: state.total,
              onCancel: () => Navigator.of(context).maybePop(),
              onSave: saving ? null : () => context.read<InvoiceBloc>().add(InvoiceSubmitted()),
              saving: saving,
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (ctx, c) {
                  final maxW = math.min(1100.0, c.maxWidth);
                  final pad = maxW < 420 ? 10.0 : 14.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(pad),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HeaderCard(
                              invoiceNo: state.invoiceNo,
                              date: state.date,
                              onPickDate: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                  initialDate: state.date,
                                );
                                if (picked != null) {
                                  context.read<InvoiceBloc>().add(InvoiceDateChanged(picked));
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomerDropdownField(
                              selectedCustomerId: state.customerId,
                              onSelected: (opt) {
                                context.read<InvoiceBloc>().add(
                                  InvoiceCustomerSelected(opt.id, opt.name, opt.address),
                                );
                              },
                            ),
                            const SizedBox(height: 12),


                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () async {
                                        final res = await showModalBottomSheet<ProductPick?>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (_) => const ProductListSheet(),
                                        );
                                        if (res != null) {
                                          context.read<InvoiceBloc>().add(
                                            InvoiceItemAdded(LineItem(
                                              productId: res.id,
                                              name: res.name,
                                              rate: res.rate,
                                              qty: 1,
                                              coverUrl: res.coverUrl,
                                            )),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                            LinesList(
                              items: state.items,
                              onChange: (i, li) => context.read<InvoiceBloc>().add(InvoiceItemUpdated(i, li)),
                              onRemove: (i) => context.read<InvoiceBloc>().add(InvoiceItemRemoved(i)),
                            ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}







// ===== Totals bar ============================================================

