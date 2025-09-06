import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../models/product_input.dart';

abstract class ProductsRepository {
  Future<List<RefItem>> getCategories();
  Future<List<RefItem>> getBrands();

  /// Creates a new product document and uploads images.
  /// Returns the created document ID.
  Future<String> createProductWithImages({
    required ProductDraft draft,
    required List<File> images,
  });
}

class FirestoreProductsRepository implements ProductsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  FirestoreProductsRepository({
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<List<RefItem>> getCategories() async {
    final snap = await _db.collection('product_category').orderBy('name').get();
    return snap.docs
        .map((d) => RefItem(id: d.id, name: (d.data()['name'] as String)))
        .toList();
  }

  @override
  Future<List<RefItem>> getBrands() async {
    final snap = await _db.collection('product_brand').orderBy('name').get();
    return snap.docs
        .map((d) => RefItem(id: d.id, name: (d.data()['name'] as String)))
        .toList();
  }

  @override
  Future<String> createProductWithImages({
    required ProductDraft draft,
    required List<File> images,
  }) async {
    // Pre-create a doc ref so we can upload to a stable path
    final docRef = _db.collection('product_master').doc();
    final productId = docRef.id;

    // 1) Upload images to Storage: products/{productId}/{timestamp}.jpg
    final urls = <String>[];
    for (final file in images) {
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final ref = _storage.ref('products/$productId/$fileName.jpg');
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
    }

    // 2) Write product document in one go (includes image URLs)
    final data = draft.toFirestoreMap(imageUrls: urls)
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    await docRef.set(data);
    return productId;
  }
}
