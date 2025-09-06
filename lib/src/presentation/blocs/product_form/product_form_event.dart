import 'package:image_picker/image_picker.dart';

import '../../../data/models/product_input.dart';

abstract class ProductFormEvent {}

class ProductFormStarted extends ProductFormEvent {}

class ProductNameChanged extends ProductFormEvent { final String v; ProductNameChanged(this.v); }
class ProductCategoryChanged extends ProductFormEvent { final RefItem? v; ProductCategoryChanged(this.v); }
class ProductBrandChanged extends ProductFormEvent { final RefItem? v; ProductBrandChanged(this.v); }
class ProductPurchaseRateChanged extends ProductFormEvent { final String v; ProductPurchaseRateChanged(this.v); }
class ProductSalesRateChanged extends ProductFormEvent { final String v; ProductSalesRateChanged(this.v); }

class ProductImagesPicked extends ProductFormEvent { final List<XFile> files; ProductImagesPicked(this.files); }
class ProductImageRemoved extends ProductFormEvent { final int index; ProductImageRemoved(this.index); }

class ProductFormSubmitted extends ProductFormEvent {}
