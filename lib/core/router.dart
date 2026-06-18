import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/daily/daily_page.dart';
import '../features/auth/auth_screen.dart';
import '../features/onboarding/onboarding_flow.dart';

final appRouter = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => const _LoadingScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingFlow(
        onDone: () => context.go('/daily'),
      ),
    ),
    GoRoute(
      path: '/daily',
      builder: (context, state) => const DailyPage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
  ],
);

class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final onboarded = await checkOnboarded();
    if (mounted) {
      context.go(onboarded ? '/daily' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
