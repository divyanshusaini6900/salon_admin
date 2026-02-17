import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/theme.dart';
import '../../app/firebase_bootstrap.dart';
import '../../shared/widgets/responsive.dart';
import '../../data/firebase/firestore_service.dart';
import 'admin_booking.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final firestore = AdminFirestoreService(FirebaseFirestore.instance);
    final stream = FirebaseBootstrap.enableFirebase
        ? firestore.watchBookings()
        : Stream.value(_demoBookings);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person_outline)),
        ],
        title: const Text('Bookings'),
      ),
      body: StreamBuilder<List<AdminBooking>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load bookings'));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet'));
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
            children: [
              Text('Todays queue', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: const [
                  _FilterChip(label: 'All', selected: true),
                  _FilterChip(label: 'Confirmed'),
                  _FilterChip(label: 'Pending'),
                  _FilterChip(label: 'Cancelled'),
                ],
              ),
              const SizedBox(height: 16),
              for (final booking in bookings) ...[
                _BookingTile(
                  customer: booking.customerName,
                  service: booking.serviceName,
                  time: DateFormat('hh:mm a').format(booking.dateTime),
                  stylist: booking.stylistName,
                  status: booking.status,
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? AdminColors.accent.withOpacity(0.25) : const Color(0xFFEFF2F8),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.customer,
    required this.service,
    required this.time,
    required this.stylist,
    required this.status,
  });

  final String customer;
  final String service;
  final String time;
  final String stylist;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE7ECF6), child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('$service ? $time', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
                Text('Stylist: ${stylist}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'Confirmed' ? AdminColors.success.withOpacity(0.12) : const Color(0xFFFFE9B5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

final _demoBookings = <AdminBooking>[
  AdminBooking(
    id: '1',
    customerName: 'Ananya Rai',
    serviceName: 'Luxe Color Blend',
    stylistName: 'Ariana',
    dateTime: DateTime(2026, 2, 17, 13, 30),
    timeSlot: '1:30 PM',
    status: 'Confirmed',
    price: 2450,
  ),
  AdminBooking(
    id: '2',
    customerName: 'Rohit Shah',
    serviceName: 'Signature Haircut',
    stylistName: 'Yoyo',
    dateTime: DateTime(2026, 2, 17, 14, 15),
    timeSlot: '2:15 PM',
    status: 'Pending',
    price: 1200,
  ),
  AdminBooking(
    id: '3',
    customerName: 'Kiara Mehta',
    serviceName: 'Scalp Renewal Spa',
    stylistName: 'Maya',
    dateTime: DateTime(2026, 2, 17, 15, 0),
    timeSlot: '3:00 PM',
    status: 'Confirmed',
    price: 1800,
  ),
];
