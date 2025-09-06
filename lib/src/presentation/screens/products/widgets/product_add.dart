import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_test_app/src/presentation/screens/products/product_form_screen.dart';
import 'package:sales_test_app/src/presentation/screens/products/widgets/header_painter.dart';
import 'package:sales_test_app/src/presentation/screens/products/widgets/pricing_card.dart';

import '../../../../data/repositories/product_input_repository.dart';
import '../../../blocs/product_form/product_form_bloc.dart';
import '../../../blocs/product_form/product_form_event.dart';
import '../../../blocs/product_form/product_form_state.dart';
import 'basic_info_card.dart';
import 'image_card.dart';

class ProductAddPageState extends State<ProductAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _pr = TextEditingController();
  final _sr = TextEditingController();

  @override
  void dispose() { _name.dispose(); _pr.dispose(); _sr.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductFormBloc(repo: FirestoreProductsRepository())..add(ProductFormStarted()),
      child: BlocConsumer<ProductFormBloc, ProductFormState>(
        listener: (context, state) {
          if (state.status == ProductFormStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.status == ProductFormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product saved ✅')));
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final loadingRefs = state.status == ProductFormStatus.loading;
          final submitting = state.status == ProductFormStatus.submitting;
          final progress = _progressForHeader(state);

          return Scaffold(
            appBar: AppBar(
              title: const Text('New Product'),
              actions: [
                TextButton.icon(
                  onPressed: submitting ? null : () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<ProductFormBloc>().add(ProductFormSubmitted());
                  },
                  icon: submitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ],
            ),
            body: Stack(
              children: [
                _GradientHeader(progress: progress),
                SafeArea(
                  child: loadingRefs
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                    builder: (ctx, c) {
                      final w = c.maxWidth;
                      final maxW = math.min(1100.0, w);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 110, 16, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxW),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ImagesCard(
                                  files: state.images,
                                  onPick: (files) => context.read<ProductFormBloc>().add(ProductImagesPicked(files)),
                                  onRemove: (i) => context.read<ProductFormBloc>().add(ProductImageRemoved(i)),
                                ),
                                const SizedBox(height: 14),
                                BasicInfoCard(
                                  formKey: _formKey,
                                  nameCtrl: _name,
                                  onNameChanged: (v) => context.read<ProductFormBloc>().add(ProductNameChanged(v)),
                                  categories: state.categories,
                                  selectedCategory: state.category,
                                  onCategoryChanged: (v) => context.read<ProductFormBloc>().add(ProductCategoryChanged(v)),
                                  brands: state.brands,
                                  selectedBrand: state.brand,
                                  onBrandChanged: (v) => context.read<ProductFormBloc>().add(ProductBrandChanged(v)),
                                ),
                                const SizedBox(height: 14),
                                PricingCard(
                                  purchaseCtrl: _pr,
                                  salesCtrl: _sr,
                                  onPurchaseChanged: (v) => context.read<ProductFormBloc>().add(ProductPurchaseRateChanged(v)),
                                  onSalesChanged: (v) => context.read<ProductFormBloc>().add(ProductSalesRateChanged(v)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _progressForHeader(ProductFormState s) {
    var f = 0;
    if (s.name.trim().isNotEmpty) f++;
    if (s.category != null) f++;
    if (s.brand != null) f++;
    if ((double.tryParse(s.purchaseRate) ?? -1) >= 0) f++;
    if ((double.tryParse(s.salesRate) ?? -1) >= 0) f++;
    return (f / 5).clamp(0, 1).toDouble();
  }
}

class _GradientHeader extends StatelessWidget {
  final double progress;
  const _GradientHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox.expand(
      child: CustomPaint(
        painter: HeaderPainter(
          LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [cs.primary, cs.secondary],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Product Composer',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
              const SizedBox(height: 6),
              Text('You\'re ${(progress * 100).round()}% done',
                  style: TextStyle(color: Colors.white.withOpacity(.95))),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}