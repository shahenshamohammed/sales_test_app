// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
//
// import '../../../data/models/product_list.dart';
// import '../../../data/repositories/product_query_repository.dart';
// import '../../blocs/product_list/product_list_bloc.dart';
// import '../../blocs/product_list/product_list_event.dart';
// import '../../blocs/product_list/product_list_state.dart';
//
// class ProductListPage extends StatefulWidget {
//   const ProductListPage({super.key});
//   @override
//   State<ProductListPage> createState() => _ProductListPageState();
// }
//
// class _ProductListPageState extends State<ProductListPage> {
//   final _scroll = ScrollController();
//   final _search = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _scroll.addListener(() {
//       final c = _scroll.position;
//       if (c.pixels >= c.maxScrollExtent - 240) {
//         context.read<ProductListBloc>().add(ProductListNextPageRequested());
//       }
//     });
//   }
//
//   @override
//   void dispose() { _scroll.dispose(); _search.dispose(); super.dispose(); }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ProductListBloc(repo: FirestoreProductQueryRepository())..add(ProductListStarted()),
//       child: BlocBuilder<ProductListBloc, ProductListState>(
//         builder: (context, state) {
//           final isLoading = state.status == ProductListStatus.loading;
//           final isPaginating = state.status == ProductListStatus.paginating;
//
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Products'),
//               actions: [
//                 IconButton(
//                   tooltip: 'Add Product',
//                   onPressed: () => Navigator.of(context).pushNamed('/products/new'),
//                   icon: const Icon(Icons.add),
//                 ),
//               ],
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(64),
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                   child: TextField(
//                     controller: _search,
//                     onChanged: (v) => context.read<ProductListBloc>().add(ProductListSearchChanged(v)),
//                     decoration: InputDecoration(
//                       hintText: 'Search products...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             body: RefreshIndicator(
//               onRefresh: () async => context.read<ProductListBloc>().add(ProductListRefreshed()),
//               child: isLoading
//                   ? _GridSkeleton(controller: _scroll)
//                   : (state.status == ProductListStatus.empty)
//                   ? const _EmptyView()
//                   : CustomScrollView(
//                 controller: _scroll,
//                 slivers: [
//                   SliverPadding(
//                     padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
//                     sliver: SliverGrid(
//                       delegate: SliverChildBuilderDelegate(
//                             (context, i) {
//                           if (i >= state.items.length) {
//                             return const _PaginatingTile();
//                           }
//                           return _ProductCard(item: state.items[i]);
//                         },
//                         childCount: state.items.length + (isPaginating ? 1 : 0),
//                       ),
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,                 // adaptive feel via aspect ratio + padding
//                         mainAxisSpacing: 12, crossAxisSpacing: 12,
//                         childAspectRatio: .78,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// /// ---- Widgets ---------------------------------------------------------------
//
// class _ProductCard extends StatelessWidget {
//   final Product item;
//   const _ProductCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Card(
//       elevation: 3,
//       clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: () {
//           // TODO: Navigator.pushNamed(context, '/products/${item.id}');
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Image
//             AspectRatio(
//               aspectRatio: 1.2,
//               child: item.coverUrl == null || item.coverUrl!.isEmpty
//                   ? Container(
//                 color: cs.surfaceVariant.withOpacity(.6),
//                 child: const Center(child: Icon(Icons.inventory_2_outlined, size: 40)),
//               )
//                   : CachedNetworkImage(
//                 imageUrl: item.coverUrl!,
//                 fit: BoxFit.cover,
//                 fadeInDuration: const Duration(milliseconds: 200),
//                 placeholder: (ctx, url) => Container(
//                   color: cs.surfaceVariant.withOpacity(.6),
//                   child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//                 ),
//                 errorWidget: (ctx, url, err) => Container(
//                   color: cs.surfaceVariant.withOpacity(.6),
//                   child: const Center(child: Icon(Icons.broken_image_outlined)),
//                 ),
//               ),
//             ),
//             // Info
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontWeight: FontWeight.w700)),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       Icon(Icons.sell_outlined, size: 16, color: cs.primary),
//                       const SizedBox(width: 4),
//                       Text('${item.salesRate}',
//                           style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary)),
//                       const Spacer(),
//                       Text('Buy ${item.purchaseRate}',
//                           style: TextStyle(color: cs.outline)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyView extends StatelessWidget {
//   const _EmptyView();
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: const [
//         SizedBox(height: 120),
//         Icon(Icons.inventory_2_outlined, size: 64),
//         SizedBox(height: 12),
//         Center(child: Text('No products yet')),
//       ],
//     );
//   }
// }
//
// class _PaginatingTile extends StatelessWidget {
//   const _PaginatingTile();
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: CircularProgressIndicator(strokeWidth: 2));
//   }
// }
//
// /// Simple skeleton while first page loads
// class _GridSkeleton extends StatelessWidget {
//   final ScrollController controller;
//   const _GridSkeleton({required this.controller});
//   @override
//   Widget build(BuildContext context) {
//     final tiles = List.generate(6, (i) => _SkeletonCard());
//     return CustomScrollView(
//       controller: controller,
//       slivers: [
//         SliverPadding(
//           padding: const EdgeInsets.all(12),
//           sliver: SliverGrid(
//             delegate: SliverChildListDelegate(tiles),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .78),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _SkeletonCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final base = Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6);
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         children: [
//           Expanded(child: Container(decoration: BoxDecoration(color: base, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))))),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 Container(height: 14, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(child: Container(height: 12, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6)))),
//                     const SizedBox(width: 12),
//                     Container(width: 46, height: 12, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
