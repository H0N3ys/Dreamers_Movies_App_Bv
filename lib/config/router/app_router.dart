import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/splash_screen.dart';
// 1. IMPORTA LA NUEVA PANTALLA (Ajusta la ruta si la guardaste en otra carpeta)
import 'package:dreamers_movies_app_bv/presentation/screens/auth/local_auth_screen.dart';

final appRouter = GoRouter(
  initialLocation: "/splash",

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

    // 2. AGREGA LA RUTA DE LA HUELLA AQUÍ:
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