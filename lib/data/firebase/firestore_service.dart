import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFirestoreService {
  AdminFirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> updateServiceImage({required String serviceId, required String imageUrl}) async {
    await _firestore.collection('services').doc(serviceId).set({
      'imageUrl': imageUrl,
    }, SetOptions(merge: true));
  }
}
