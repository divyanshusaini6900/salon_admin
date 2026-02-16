import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/firebase/firestore_service.dart';
import '../../data/firebase/storage_service.dart';

import '../../app/theme.dart';
import '../../shared/widgets/responsive.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isWide = Responsive.isDesktop(context);

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
      body: ListView(
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
            children: const [
              SizedBox(width: 260, child: StatCard(title: 'Todays Bookings', value: '38', delta: '+12% vs yesterday', icon: Icons.event_available)),
              SizedBox(width: 260, child: StatCard(title: 'Revenue', value: '?72,450', delta: '+8.3% vs last week', icon: Icons.payments_rounded)),
              SizedBox(width: 260, child: StatCard(title: 'Avg. Rating', value: '4.86', delta: '? +0.04 this month', icon: Icons.star_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RevenuePanel()),
                    const SizedBox(width: 20),
                    Expanded(child: _UpcomingPanel()),
                  ],
                )
              : Column(
                  children: const [
                    _RevenuePanel(),
                    SizedBox(height: 20),
                    _UpcomingPanel(),
                  ],
                ),
          const SizedBox(height: 24),
          _TeamLoadPanel(),
          const SizedBox(height: 24),
          const _ServiceImageUpload(),
        ],
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
  const _UpcomingPanel();

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
          const _BookingRow(name: 'Ananya Rai', service: 'Luxe Color Blend', time: '1:30 PM'),
          const Divider(),
          const _BookingRow(name: 'Rohit Shah', service: 'Signature Haircut', time: '2:15 PM'),
          const Divider(),
          const _BookingRow(name: 'Kiara Mehta', service: 'Scalp Renewal Spa', time: '3:00 PM'),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Team load & availability', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: const [
              _StaffChip(name: 'Yoyo', load: '90%'),
              _StaffChip(name: 'Maya', load: '75%'),
              _StaffChip(name: 'Rhea', load: '62%'),
              _StaffChip(name: 'Ariana', load: '80%'),
            ],
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
