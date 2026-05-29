import 'package:dreamers_movies_app_bv/presentation/screens/movies/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/presentation/auth/login_screen.dart';
final appRouter = GoRouter(
  initialLocation: "/login", 
  
  routes: [
    // Ruta del Login
    GoRoute(
      path: "/login",
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),

    // Ruta del Home 
    GoRoute(
      path: "/",
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    )
  ]
);
