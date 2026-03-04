import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/presentation/screens/home_screen.dart';
import '../features/presentation/screens/login_screen.dart';
import '../features/presentation/screens/signup_screen.dart';
import '../features/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup';

      // If user is logged in and on auth page → go to home
      if (isLoggedIn && isOnAuthPage) return '/home';

      // If user is NOT logged in and NOT on auth page → go to login
      if (!isLoggedIn && !isOnAuthPage) return '/login';

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
