import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';

final appRouter = GoRouter(
  initialLocation: "/login",

  routes: [
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
      path: "/",
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);