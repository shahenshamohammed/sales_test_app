

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_input_int.dart';

abstract class CustomerRepository {
  Future<String> createCustomer(CustomerInput input); // returns new doc id
}

class FirestoreCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _db;
  FirestoreCustomerRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> createCustomer(CustomerInput input) async {
    final ref = _db.collection('customer master').doc();
    final data = input.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return ref.id;
  }
}
