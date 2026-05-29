import 'package:dreamers_movies_app_bv/presentation/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: "/login", 
  
  routes: [
    // Ruta del Login
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

    // Ruta del Home 
    GoRoute(
      path: "/",
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    )
  ]
);
