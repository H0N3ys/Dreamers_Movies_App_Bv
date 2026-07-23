import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/profile/user_details_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/splash_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/local_auth_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/home_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/search_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',

  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final estaAutenticado = session != null;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToSplash = state.matchedLocation == '/splash';

    if (!estaAutenticado &&
        !isGoingToLogin &&
        !isGoingToRegister &&
        !isGoingToSplash) {
      return '/login';
    }

    if (estaAutenticado && (isGoingToLogin || isGoingToRegister)) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/local-auth',
      name: LocalAuthScreen.name,
      builder: (context, state) => const LocalAuthScreen(),
    ),
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      name: SearchScreen.name,
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);
