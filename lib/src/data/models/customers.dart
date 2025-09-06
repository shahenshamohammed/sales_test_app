import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String docId;
  final String name;
  final String address;
  final String areaId;
  final String categoryId;
  final String? areaName;
  final String? categoryName;
  final Timestamp? createdAt;

  const Customer({
    required this.docId,
    required this.name,
    required this.address,
    required this.areaId,
    required this.categoryId,
    this.areaName,
    this.categoryName,
    this.createdAt,
  });

  factory Customer.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    return Customer(
      docId: d.id,
      name: (data['name'] ?? '') as String,
      address: (data['address'] ?? '') as String,
      areaId: (data['areaId'] ?? '') as String,
      categoryId: (data['categoryId'] ?? '') as String,
      areaName: (data['areaName'] as String?),
      categoryName: (data['categoryName'] as String?),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
