import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app/firebase_bootstrap.dart';
import '../../data/firebase/firestore_service.dart';
import '../../data/firebase/storage_service.dart';
import '../../features/bookings/admin_booking.dart';
import '../../features/staff/admin_stylist.dart';

import '../../app/theme.dart';
import '../../shared/widgets/responsive.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isWide = Responsive.isDesktop(context);
    final firestore = AdminFirestoreService(FirebaseFirestore.instance);
    final bookingsStream = FirebaseBootstrap.enableFirebase
        ? firestore.watchBookings()
        : Stream.value(_demoBookings);
    final stylistsStream = FirebaseBootstrap.enableFirebase
        ? firestore.watchStylists()
        : Stream.value(_demoStylists);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE7ECF6), child: Icon(Icons.person)),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<AdminBooking>>(
        stream: bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load dashboard data'));
          }
          final bookings = snapshot.data ?? [];
          final totalBookings = bookings.length;
          final revenue = bookings.fold<double>(0, (sum, item) => sum + item.price);
          final avgRating = bookings.isEmpty ? 4.8 : 4.8;
          final upcoming = bookings
              .where((b) => b.dateTime.isAfter(DateTime.now()))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          final bookingCounts = <String, int>{};
          for (final booking in bookings) {
            final name = booking.stylistName.trim();
            if (name.isEmpty) continue;
            bookingCounts[name] = (bookingCounts[name] ?? 0) + 1;
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
            children: [
              Text('Good afternoon, Divya', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              Text("Here is today's single-salon performance snapshot.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminColors.softInk)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 260,
                    child: StatCard(
                      title: 'Todays Bookings',
                      value: totalBookings.toString(),
                      delta: '+12% vs yesterday',
                      icon: Icons.event_available,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: StatCard(
                      title: 'Revenue',
                      value: '?${revenue.toStringAsFixed(0)}',
                      delta: '+8.3% vs last week',
                      icon: Icons.payments_rounded,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: StatCard(
                      title: 'Avg. Rating',
                      value: avgRating.toStringAsFixed(2),
                      delta: '+0.04 this month',
                      icon: Icons.star_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: _RevenuePanel()),
                        const SizedBox(width: 20),
                        Expanded(child: _UpcomingPanel(bookings: upcoming.take(3).toList())),
                      ],
                    )
                  : Column(
                      children: [
                        const _RevenuePanel(),
                        const SizedBox(height: 20),
                        _UpcomingPanel(bookings: upcoming.take(3).toList()),
                      ],
                    ),
              const SizedBox(height: 24),
              StreamBuilder<List<AdminStylist>>(
                stream: stylistsStream,
                builder: (context, staffSnapshot) {
                  final stylists = staffSnapshot.data ?? const <AdminStylist>[];
                  return _TeamLoadPanel(stylists: stylists, bookingCounts: bookingCounts);
                },
              ),
              const SizedBox(height: 24),
              const _ServiceImageUpload(),
            ],
          );
        },
      ),
    );
  }
}

class _RevenuePanel extends StatelessWidget {
  const _RevenuePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('Graph placeholder')),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Metric(label: 'Peak hour', value: '6:00 PM'),
              _Metric(label: 'Avg. ticket', value: '?1,820'),
              _Metric(label: 'No-shows', value: '2%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingPanel extends StatelessWidget {
  const _UpcomingPanel({required this.bookings});

  final List<AdminBooking> bookings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming bookings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (bookings.isEmpty)
            const Text('No upcoming bookings')
          else
            Column(
              children: [
                for (int i = 0; i < bookings.length; i++) ...[
                  _BookingRow(
                    name: bookings[i].customerName,
                    service: bookings[i].serviceName,
                    time: DateFormat('hh:mm a').format(bookings[i].dateTime),
                  ),
                  if (i != bookings.length - 1) const Divider(),
                ],
              ],
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () {}, child: const Text('View all bookings')),
          ),
        ],
      ),
    );
  }
}

class _TeamLoadPanel extends StatelessWidget {
  const _TeamLoadPanel({required this.stylists, required this.bookingCounts});

  final List<AdminStylist> stylists;
  final Map<String, int> bookingCounts;

  @override
  Widget build(BuildContext context) {
    final maxCount = bookingCounts.values.isEmpty ? 1 : bookingCounts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Team load & availability', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (stylists.isEmpty)
            const Text('No staff found')
          else
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: stylists.map((stylist) {
                final count = bookingCounts[stylist.name] ?? 0;
                final load = ((count / maxCount) * 100).clamp(10, 100).toStringAsFixed(0);
                return _StaffChip(name: stylist.name, load: '$load%');
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ServiceImageUpload extends StatefulWidget {
  const _ServiceImageUpload();

  @override
  State<_ServiceImageUpload> createState() => _ServiceImageUploadState();
}

class _ServiceImageUploadState extends State<_ServiceImageUpload> {
  final _controller = TextEditingController();
  bool _uploading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _upload(BuildContext context) async {
    final serviceId = _controller.text.trim();
    if (serviceId.isEmpty) return;

    setState(() => _uploading = true);
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      if (mounted) setState(() => _uploading = false);
      return;
    }

    try {
      final storage = AdminStorageService(FirebaseStorage.instance);
      final url = await storage.uploadServiceImage(serviceId: serviceId, file: File(file.path));
      final firestore = AdminFirestoreService(FirebaseFirestore.instance);
      await firestore.updateServiceImage(serviceId: serviceId, imageUrl: url);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Service image uploaded')));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Upload failed')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service image upload', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Attach or update a service image in Storage.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Enter service ID e.g. cut'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _uploading ? null : () => _upload(context),
                child: Text(_uploading ? 'Uploading...' : 'Upload'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.name, required this.service, required this.time});

  final String name;
  final String service;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE8ECF5), child: Icon(Icons.person, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.bodyMedium),
              Text(service, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
            ],
          ),
        ),
        Text(time, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StaffChip extends StatelessWidget {
  const _StaffChip({required this.name, required this.load});

  final String name;
  final String load;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AdminColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(load, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.ink)),
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

final _demoStylists = <AdminStylist>[
  AdminStylist(name: 'Yoyo', level: 'Senior'),
  AdminStylist(name: 'Maya', level: 'Stylist'),
  AdminStylist(name: 'Rhea', level: 'Stylist'),
  AdminStylist(name: 'Ariana', level: 'Senior'),
];
