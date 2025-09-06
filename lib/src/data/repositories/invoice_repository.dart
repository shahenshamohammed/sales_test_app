import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_form.dart';


abstract class InvoicesRepository {
  Future<String> create(InvoiceDraft draft);
}

class FirestoreInvoicesRepository implements InvoicesRepository {
  final FirebaseFirestore _db;
  final String saleCollection;
  FirestoreInvoicesRepository({
    FirebaseFirestore? db,
    this.saleCollection = 'sales', // <- user asked: save to `sale`
  }) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> create(InvoiceDraft draft) async {
    final saleRef = _db.collection(saleCollection).doc();
    await saleRef.set(draft.toHeaderMap());
    final batch = _db.batch();
    final itemsRef = saleRef.collection('items');
    for (final li in draft.items) {
      batch.set(itemsRef.doc(), li.toMap());
    }
    await batch.commit();
    return saleRef.id;
  }
}
