import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.stylistName,
    required this.dateTime,
    required this.timeSlot,
    required this.status,
    required this.price,
  });

  final String id;
  final String customerName;
  final String serviceName;
  final String stylistName;
  final DateTime dateTime;
  final String timeSlot;
  final String status;
  final double price;

  factory AdminBooking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['dateTime'] as Timestamp?;
    return AdminBooking(
      id: doc.id,
      customerName: data['customerName'] as String? ?? 'Customer',
      serviceName: data['serviceName'] as String? ?? 'Service',
      stylistName: data['stylistName'] as String? ?? 'Stylist',
      dateTime: timestamp?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] as String? ?? '',
      status: data['status'] as String? ?? 'Confirmed',
      price: (data['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
