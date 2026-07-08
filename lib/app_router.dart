import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dreamers_movies_app_bv/presentation/screens/splash_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/local_auth_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/home_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/search_screen.dart';

import 'package:dreamers_movies_app_bv/presentation/screens/errors/error_404_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/errors/error_500_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',

  // Si todo falla en las rutas, esto dibuja tu pantalla 404
  errorBuilder: (context, state) => const Error404Screen(),

  redirect: (context, state) {
    // Usamos state.uri.path porque es el string real de hacia dónde intenta ir el usuario
    final location = state.uri.path;

    final session = Supabase.instance.client.auth.currentSession;
    final estaAutenticado = session != null;

    final isGoingToLogin = location == '/login';
    final isGoingToRegister = location == '/register';
    final isGoingToSplash = location == '/splash';
    final isGoingToServerError = location == '/server-error';

    // Si va a una ruta que no existe (404), no lo mandes al login, deja que pase al errorBuilder
    final rutasValidas = ['/splash', '/login', '/register', '/local-auth', '/', '/search', '/server-error'];
    if (!rutasValidas.contains(location)) {
      return null;
    }

    if (!estaAutenticado &&
        !isGoingToLogin &&
        !isGoingToRegister &&
        !isGoingToSplash &&
        !isGoingToServerError) {
      return '/login';
    }

    if (estaAutenticado && (isGoingToLogin || isGoingToRegister)) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/server-error',
      builder: (context, state) => const Error500Screen(),
    ),
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