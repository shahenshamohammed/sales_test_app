
import '../../../data/models/ref_item_int.dart';

enum CustomerFormStatus { initial, loading, ready, submitting, success, failure }

class CustomerFormState {
  final CustomerFormStatus status;
  final String? error;

  final List<RefItem> areas;
  final List<RefItem> categories;

  final String name;
  final String address;
  final RefItem? selectedArea;
  final RefItem? selectedCategory;

  const CustomerFormState({
    this.status = CustomerFormStatus.initial,
    this.error,
    this.areas = const [],
    this.categories = const [],
    this.name = '',
    this.address = '',
    this.selectedArea,
    this.selectedCategory,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
          address.trim().isNotEmpty &&
          selectedArea != null &&
          selectedCategory != null;

  double get progress {
    var f = 0;
    if (name.trim().isNotEmpty) f++;
    if (address.trim().isNotEmpty) f++;
    if (selectedArea != null) f++;
    if (selectedCategory != null) f++;
    return (f / 4).clamp(0, 1).toDouble();
  }

  CustomerFormState copyWith({
    CustomerFormStatus? status,
    String? error,
    List<RefItem>? areas,
    List<RefItem>? categories,
    String? name,
    String? address,
    RefItem? selectedArea,
    RefItem? selectedCategory,
    bool clearError = false,
  }) {
    return CustomerFormState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      areas: areas ?? this.areas,
      categories: categories ?? this.categories,
      name: name ?? this.name,
      address: address ?? this.address,
      selectedArea: selectedArea ?? this.selectedArea,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  factory CustomerFormState.initial() => const CustomerFormState();
}
