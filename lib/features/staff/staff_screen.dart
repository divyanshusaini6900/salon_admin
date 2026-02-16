import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/responsive.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person_outline)),
        ],title: const Text('Staff & Schedule')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
        children: [
          Text('Todays roster', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const _StaffTile(name: 'Yoyo', role: 'Master Stylist', shift: '11 AM - 8 PM', load: '90%'),
          const SizedBox(height: 12),
          const _StaffTile(name: 'Ariana', role: 'Color Expert', shift: '10 AM - 7 PM', load: '75%'),
          const SizedBox(height: 12),
          const _StaffTile(name: 'Maya', role: 'Texture Specialist', shift: '12 PM - 9 PM', load: '62%'),
          const SizedBox(height: 24),
          Text('Notes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Two extra assistants added for the evening rush. Keep premium products stocked for balayage services.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminColors.softInk),
          ),
        ],
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.name, required this.role, required this.shift, required this.load});

  final String name;
  final String role;
  final String shift;
  final String load;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, backgroundColor: Color(0xFFE7ECF6), child: Icon(Icons.person_outline)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(role, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
                Text('Shift: $shift', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F4FA), borderRadius: BorderRadius.circular(12)),
            child: Text(load, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
