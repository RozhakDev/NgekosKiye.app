import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';

import '../../features/kost/presentation/screens/dashboard_screen.dart';
import '../../features/kost/presentation/screens/kost_detail_screen.dart';
import '../../features/kost/presentation/screens/kost_map_screen.dart';

import '../../features/booking/presentation/screens/payment_screen.dart';
import '../../features/booking/presentation/screens/booking_history_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';

final authStateProvider = StateProvider<bool>((ref) => false);

final goRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';
      final requiresAuth = state.matchedLocation.startsWith('/payment') || state.matchedLocation.startsWith('/history') || state.matchedLocation.startsWith('/profile');

      if (!isLoggedIn && requiresAuth) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? state.extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/kost/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return KostDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return KostMapScreen(
            lat: double.parse(args['lat'].toString()),
            lng: double.parse(args['lng'].toString()),
            title: args['name'],
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/payment/:bookingId/:kostId',
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          final kostId = int.parse(state.pathParameters['kostId']!);
          final totalPrice = state.extra as String? ?? '0';
          return PaymentScreen(bookingId: bookingId, kostId: kostId, totalPrice: totalPrice);
        },
      ),
    ],
  );
});

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}