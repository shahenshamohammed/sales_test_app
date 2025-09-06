import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String categoryId;
  final String brandId;
  final double purchaseRate;
  final double salesRate;
  final String? coverUrl;            // first image (optional)
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.brandId,
    required this.purchaseRate,
    required this.salesRate,
    required this.imageUrls,
    this.coverUrl,
  });

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Product(
      id: d.id,
      name: m['name'] ?? '',
      categoryId: m['categoryId'] ?? '',
      brandId: m['brandId'] ?? '',
      purchaseRate: (m['purchaseRate'] as num?)?.toDouble() ?? 0,
      salesRate: (m['salesRate'] as num?)?.toDouble() ?? 0,
      imageUrls: (m['imageUrls'] as List?)?.cast<String>() ?? const [],
      coverUrl: m['coverUrl'] as String?,
    );
  }
}


