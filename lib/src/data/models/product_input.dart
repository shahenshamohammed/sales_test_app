class RefItem {
  final String id;
  final String name;
  const RefItem({required this.id, required this.name});
}

class ProductDraft {
  final String name;
  final String categoryId;
  final String brandId;
  final double purchaseRate;
  final double salesRate;

  const ProductDraft({
    required this.name,
    required this.categoryId,
    required this.brandId,
    required this.purchaseRate,
    required this.salesRate,
  });

  Map<String, dynamic> toFirestoreMap({
    required List<String> imageUrls,
  }) {
    return {
      'name': name.trim(),
      'nameLower': name.trim().toLowerCase(),
      'categoryId': categoryId,
      'brandId': brandId,
      'purchaseRate': purchaseRate,
      'salesRate': salesRate,
      'imageUrls': imageUrls,
      'coverUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
    };
  }
}
