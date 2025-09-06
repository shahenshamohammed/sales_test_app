import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import 'widgets/customer_action_bar.dart';
import 'widgets/customer_add_screen_bg.dart';
import 'widgets/customer_form_card.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/reference_repositories.dart';
import '../../blocs/customer_forms/customer_form_bloc.dart';
import '../../blocs/customer_forms/customer_form_event.dart';
import '../../blocs/customer_forms/customer_form_state.dart';


class CustomerAddPage extends StatefulWidget {
  const CustomerAddPage({super.key});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() { _name.dispose(); _address.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerFormBloc(
        refs: FirestoreReferenceRepository(),
        repo: FirestoreCustomerRepository(),
      )..add(CustomerFormStarted()),
      child: BlocConsumer<CustomerFormBloc, CustomerFormState>(
        listener: (context, state) {
          if (state.status == CustomerFormStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.status == CustomerFormStatus.success) {

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer saved ✅')));
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final isLoading = state.status == CustomerFormStatus.loading;
          final isSubmitting = state.status == CustomerFormStatus.submitting;
          final progress = state.progress;

          void onSave() {
            if (!_formKey.currentState!.validate()) return;
            context.read<CustomerFormBloc>().add(CustomerFormSubmitted());
          }

          void onReset() {
            _formKey.currentState?.reset();
            _name.clear();
            _address.clear();
            final b = context.read<CustomerFormBloc>();
            b..add(CustomerNameChanged(''))
              ..add(CustomerAddressChanged(''))
              ..add(CustomerAreaChanged(null))
              ..add(CustomerCategoryChanged(null));
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                CustomerHeroBackground(progress: progress),

                if (isLoading)
                  const SafeArea(child: Center(child: CircularProgressIndicator()))
                else
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (ctx, c) {
                        final w = c.maxWidth;
                        final pad = w < 420 ? 12.0 : 20.0;
                        final form = Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: math.min(1100, w)),
                            child: CustomerFormCard(
                              formKey: _formKey,
                              name: _name,
                              address: _address,
                              // NEW: pass items & selected from state
                              areas: state.areas,
                              categories: state.categories,
                              selectedArea: state.selectedArea,
                              selectedCategory: state.selectedCategory,
                              onNameChanged: (v) => context.read<CustomerFormBloc>().add(CustomerNameChanged(v)),
                              onAddressChanged: (v) => context.read<CustomerFormBloc>().add(CustomerAddressChanged(v)),
                              onAreaChanged: (v) => context.read<CustomerFormBloc>().add(CustomerAreaChanged(v)),
                              onCategoryChanged: (v) => context.read<CustomerFormBloc>().add(CustomerCategoryChanged(v)),
                              topMargin: math.max(120, 140 - (w / 20)),
                              horizontalPadding: pad,
                            ),
                          ),
                        );
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 96),
                          child: form,
                        );
                      },
                    ),
                  ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomerActionsBar(
                    onSave: isSubmitting ? (){} : onSave,
                    onReset: isSubmitting ? (){} : onReset,
                  ),
                ),
                Positioned(
                  // keep it just below the status bar
                  top: MediaQuery.of(context).padding.top + 2,
                  right: 12,
                  child: IconButton.filled(
                    // use close on the right (reads better than a back arrow on the right)
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.18),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(10),
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, true); // return result to refresh previous list
                      } else {
                        Navigator.of(context).pushReplacementNamed('/customers'); // fallback
                      }
                    },
                    tooltip: 'Back',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
