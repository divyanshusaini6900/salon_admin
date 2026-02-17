import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/bookings/admin_booking.dart';
import '../../features/staff/admin_stylist.dart';

class AdminFirestoreService {
  AdminFirestoreService(this._firestore);

  final FirebaseFirestore _firestore;


  Stream<List<AdminBooking>> watchBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AdminBooking.fromDoc).toList());
  }

  Stream<List<AdminStylist>> watchStylists() {
    return _firestore.collection('stylists').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminStylist(
          name: data['name'] as String? ?? doc.id,
          level: data['level'] as String? ?? 'Stylist',
        );
      }).toList();
    });
  }

  Future<void> updateServiceImage({required String serviceId, required String imageUrl}) async {
    await _firestore.collection('services').doc(serviceId).set({
      'imageUrl': imageUrl,
    }, SetOptions(merge: true));
  }
}
