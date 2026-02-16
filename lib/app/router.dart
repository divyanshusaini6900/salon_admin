import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bookings/bookings_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/staff/staff_screen.dart';
import 'shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/auth/login',
    redirect: (context, state) {
      final isAuthed = ref.watch(authStatusProvider);
      final isLoggingIn = state.matchedLocation.startsWith('/auth');
      if (!isAuthed && !isLoggingIn) return '/auth/login';
      if (isAuthed && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const AdminSignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/profile', builder: (context, state) => const AdminProfileScreen()),
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/bookings', builder: (context, state) => const AdminBookingsScreen()),
          GoRoute(path: '/staff', builder: (context, state) => const StaffScreen()),
          GoRoute(path: '/insights', builder: (context, state) => const InsightsScreen()),
        ],
      ),
    ],
  );
});
