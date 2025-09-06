import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/product_input.dart';
import '../../../data/repositories/product_input_repository.dart';
import 'product_form_event.dart';
import 'product_form_state.dart';


class ProductFormBloc extends Bloc<ProductFormEvent, ProductFormState> {
  final ProductsRepository repo;

  ProductFormBloc({required this.repo}) : super(ProductFormState.initial()) {
    on<ProductFormStarted>(_onStarted);
    on<ProductNameChanged>((e, emit) => emit(state.copyWith(name: e.v, clearError: true)));
    on<ProductCategoryChanged>((e, emit) => emit(state.copyWith(category: e.v, clearError: true)));
    on<ProductBrandChanged>((e, emit) => emit(state.copyWith(brand: e.v, clearError: true)));
    on<ProductPurchaseRateChanged>((e, emit) => emit(state.copyWith(purchaseRate: e.v, clearError: true)));
    on<ProductSalesRateChanged>((e, emit) => emit(state.copyWith(salesRate: e.v, clearError: true)));
    on<ProductImagesPicked>(_onImagesPicked);
    on<ProductImageRemoved>(_onImageRemoved);
    on<ProductFormSubmitted>(_onSubmit);
  }

  Future<void> _onStarted(ProductFormStarted e, Emitter<ProductFormState> emit) async {
    emit(state.copyWith(status: ProductFormStatus.loading, clearError: true));
    try {
      final cats = await repo.getCategories();
      final brands = await repo.getBrands();
      emit(state.copyWith(status: ProductFormStatus.ready, categories: cats, brands: brands));
    } catch (_) {
      emit(state.copyWith(status: ProductFormStatus.failure, error: 'Failed to load categories/brands.'));
    }
  }

  void _onImagesPicked(ProductImagesPicked e, Emitter<ProductFormState> emit) {
    final combined = [...state.images, ...e.files];
    emit(state.copyWith(images: combined));
  }

  void _onImageRemoved(ProductImageRemoved e, Emitter<ProductFormState> emit) {
    final imgs = [...state.images]..removeAt(e.index);
    emit(state.copyWith(images: imgs));
  }

  Future<void> _onSubmit(ProductFormSubmitted e, Emitter<ProductFormState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(status: ProductFormStatus.failure, error: 'Please complete all required fields.'));
      return;
    }
    emit(state.copyWith(status: ProductFormStatus.submitting, clearError: true));

    try {
      final draft = ProductDraft(
        name: state.name,
        categoryId: state.category!.id,
        brandId: state.brand!.id,
        purchaseRate: double.parse(state.purchaseRate),
        salesRate: double.parse(state.salesRate),
      );

      final files = state.images.map((x) => File(x.path)).toList();

      await repo.createProductWithImages(draft: draft, images: files);

      emit(state.copyWith(status: ProductFormStatus.success));
    } catch (_) {
      emit(state.copyWith(status: ProductFormStatus.failure, error: 'Could not save product.'));
    }
  }
}
