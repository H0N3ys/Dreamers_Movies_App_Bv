import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/local_auth_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: "/splash",
  
  // LÓGICA DE PROTECCIÓN DE RUTAS
  redirect: (context, state) {
    // Leemos la sesión directamente de Supabase
    final session = Supabase.instance.client.auth.currentSession;
    final estaAutenticado = session != null;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToLocalAuth = state.matchedLocation == '/local-auth';

    // Si NO está autenticado y trata de entrar a una ruta privada (como el Home)
    if (!estaAutenticado && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
      return '/login'; // Lo pateamos al login
    }

    // Si SÍ está autenticado y trata de ir al login o registro por error
    if (estaAutenticado && (isGoingToLogin || isGoingToRegister)) {
      return '/'; // Lo mandamos directo al Home
    }

    return null; // La ruta es válida, deja que pase
  },

  routes: [
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: "/login",
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: "/register",
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: "/local-auth",
      name: LocalAuthScreen.name,
      builder: (context, state) => const LocalAuthScreen(),
    ),
    GoRoute(
      path: "/",
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);