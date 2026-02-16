import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/admin_nav.dart';
import '../shared/widgets/responsive.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      body: Row(
        children: [
          if (Responsive.isTablet(context))
            AdminSideNav(
              currentIndex: index,
              onTap: (value) => _onItemTapped(context, value),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Responsive.isTablet(context)
          ? null
          : AdminBottomNav(
              currentIndex: index,
              onTap: (value) => _onItemTapped(context, value),
            ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/staff')) return 2;
    if (location.startsWith('/insights')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go('/bookings');
        return;
      case 2:
        context.go('/staff');
        return;
      case 3:
        context.go('/insights');
        return;
      default:
        context.go('/dashboard');
        return;
    }
  }
}
