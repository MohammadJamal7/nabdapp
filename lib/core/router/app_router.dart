import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/patient/presentation/patient_home_screen.dart';
import '../../features/caregiver/presentation/caregiver_home_screen.dart';
import '../navigation/navigator_key.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/';

      if (!isAuthenticated && !isLoginRoute) {
        return '/';
      }

      if (isAuthenticated && isLoginRoute) {
        final role = authState.role;
        if (role == UserRole.caregiver) {
          return '/caregiver';
        } else {
          return '/patient';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/patient',
        builder: (context, state) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: '/caregiver',
        builder: (context, state) => const CaregiverHomeScreen(),
      ),
    ],
  );
});
