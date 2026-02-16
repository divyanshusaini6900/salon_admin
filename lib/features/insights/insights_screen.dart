import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/responsive.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person_outline)),
        ],title: const Text('Insights')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
        children: [
          Text('Customer insights', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _InsightCard(
            title: 'Most booked services',
            detail: 'Signature Haircut ? 28% share',
            icon: Icons.content_cut,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            title: 'Peak booking time',
            detail: '6:00 PM to 8:00 PM',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            title: 'Top stylist',
            detail: 'Yoyo ? 4.92 rating',
            icon: Icons.star_border,
          ),
          const SizedBox(height: 24),
          Text('Retention funnel', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Text('Funnel chart placeholder')),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.detail, required this.icon});

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AdminColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AdminColors.softInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
