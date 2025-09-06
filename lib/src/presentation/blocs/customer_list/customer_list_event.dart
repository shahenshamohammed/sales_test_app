abstract class CustomerListEvent {}

class CustomerListStarted extends CustomerListEvent {}           // initial load
class CustomerListRefreshed extends CustomerListEvent {}         // pull-to-refresh
class CustomerListNextPageRequested extends CustomerListEvent {} // infinite scroll

class CustomerListAreaFilterChanged extends CustomerListEvent {
  final String? areaId;
  CustomerListAreaFilterChanged(this.areaId);
}
class CustomerListCategoryFilterChanged extends CustomerListEvent {
  final String? categoryId;
  CustomerListCategoryFilterChanged(this.categoryId);
}
class CustomerListSearchChanged extends CustomerListEvent {
  final String? text;
  CustomerListSearchChanged(this.text);
}
