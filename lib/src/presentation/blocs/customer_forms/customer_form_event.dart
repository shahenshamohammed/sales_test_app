
import '../../../data/models/ref_item_int.dart';

abstract class CustomerFormEvent {}

class CustomerFormStarted extends CustomerFormEvent {}

class CustomerNameChanged extends CustomerFormEvent {
  final String name;
  CustomerNameChanged(this.name);
}

class CustomerAddressChanged extends CustomerFormEvent {
  final String address;
  CustomerAddressChanged(this.address);
}

class CustomerAreaChanged extends CustomerFormEvent {
  final RefItem? area;
  CustomerAreaChanged(this.area);
}

class CustomerCategoryChanged extends CustomerFormEvent {
  final RefItem? category;
  CustomerCategoryChanged(this.category);
}

class CustomerFormSubmitted extends CustomerFormEvent {}
