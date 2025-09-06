import 'package:image_picker/image_picker.dart';
import '../../../data/models/product_input.dart';

enum ProductFormStatus { initial, loading, ready, submitting, success, failure }

class ProductFormState {
  final ProductFormStatus status;
  final String? error;

  final List<RefItem> categories;
  final List<RefItem> brands;

  final String name;
  final RefItem? category;
  final RefItem? brand;
  final String purchaseRate; // keep as string for input control
  final String salesRate;
  final List<XFile> images;  // local picked files

  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.error,
    this.categories = const [],
    this.brands = const [],
    this.name = '',
    this.category,
    this.brand,
    this.purchaseRate = '',
    this.salesRate = '',
    this.images = const [],
  });

  bool get isValid {
    final pr = double.tryParse(purchaseRate) ?? -1;
    final sr = double.tryParse(salesRate) ?? -1;
    return name.trim().isNotEmpty &&
        category != null &&
        brand != null &&
        pr >= 0 && sr >= 0;
  }

  ProductFormState copyWith({
    ProductFormStatus? status,
    String? error,
    List<RefItem>? categories,
    List<RefItem>? brands,
    String? name,
    RefItem? category,
    RefItem? brand,
    String? purchaseRate,
    String? salesRate,
    List<XFile>? images,
    bool clearError = false,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      purchaseRate: purchaseRate ?? this.purchaseRate,
      salesRate: salesRate ?? this.salesRate,
      images: images ?? this.images,
    );
  }

  factory ProductFormState.initial() => const ProductFormState();
}
