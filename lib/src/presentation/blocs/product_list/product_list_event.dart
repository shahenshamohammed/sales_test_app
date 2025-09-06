abstract class ProductListEvent {}
class ProductListStarted extends ProductListEvent {}
class ProductListRefreshed extends ProductListEvent {}
class ProductListNextPageRequested extends ProductListEvent {}
class ProductListSearchChanged extends ProductListEvent { final String q; ProductListSearchChanged(this.q); }
