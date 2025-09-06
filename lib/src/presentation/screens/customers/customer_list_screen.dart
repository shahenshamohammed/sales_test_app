import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_test_app/src/data/repositories/customer_list_repository.dart';

import 'widgets/add_new_customer_banner.dart';
import 'widgets/customer_filter_bar.dart';
import 'widgets/customer_list_card.dart';
import '../../blocs/customer_list/customer_list_bloc.dart';
import '../../blocs/customer_list/customer_list_event.dart';
import '../../blocs/customer_list/customer_list_state.dart';



class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final b = context.read<CustomerListBloc>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      b.add(CustomerListNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerListBloc(repo: FirestoreCustomerListRepository())
        ..add(CustomerListStarted()),
      child: BlocBuilder<CustomerListBloc, CustomerListState>(
        builder: (context, state) {
          final isLoading = state.status == CustomerListStatus.loading;
          final isPaginating = state.status == CustomerListStatus.paginating;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Customers'),
            ),
            body: RefreshIndicator(
              onRefresh: () async => context.read<CustomerListBloc>().add(CustomerListRefreshed()),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  // 1) The new banner
                  SliverToBoxAdapter(
                    child: AddCustomerBanner(
                      onAdd: () => Navigator.of(context).pushNamed('/customers'),
                    ),
                  ),
                  // 2) Filters
                  // SliverToBoxAdapter(
                  //   child: FilterBar(
                  //     areaId: state.areaId,
                  //     categoryId: state.categoryId,
                  //     search: state.search,
                  //     onSearch: (t) => context.read<CustomerListBloc>().add(CustomerListSearchChanged(t)),
                  //     onAreaChanged: (id) => context.read<CustomerListBloc>().add(CustomerListAreaFilterChanged(id)),
                  //     onCategoryChanged: (id) => context.read<CustomerListBloc>().add(CustomerListCategoryFilterChanged(id)),
                  //   ),
                  // ),
                  // 3) Content
                  if (isLoading)
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      sliver: SliverList(delegate: SliverChildBuilderDelegate(_skeletonBuilder, childCount: 6)),
                    )
                  else if (state.status == CustomerListStatus.empty)
                    const SliverToBoxAdapter(child: _EmptyView())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      sliver: SliverList.separated(
                        itemCount: state.items.length + (isPaginating ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          if (i >= state.items.length) return const _PaginatingTile();
                          final c = state.items[i];
                          return CustomerCard(customer: c);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// small helpers reused by slivers
Widget _skeletonBuilder(BuildContext context, int index) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    height: 86,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.5),
      borderRadius: BorderRadius.circular(14),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: const [
          Icon(Icons.people_outline, size: 64),
          SizedBox(height: 12),
          Text('No customers found'),
        ],
      ),
    );
  }
}

class _PaginatingTile extends StatelessWidget {
  const _PaginatingTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
