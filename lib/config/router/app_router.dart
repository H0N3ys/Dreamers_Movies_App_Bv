import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/favorites_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/splash_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/local_auth_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/home_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/search_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/profile/profile_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/movie_details_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',

redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final tieneCuenta = prefs.getBool('is_logged_in') ?? false;
    final estaDesbloqueado = prefs.getBool('session_unlocked') ?? false;

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToLocalAuth = state.matchedLocation == '/local-auth';

    if (!tieneCuenta && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
      return '/login';
    }

    if (tieneCuenta && !estaDesbloqueado) {
      if (!isGoingToLogin && !isGoingToLocalAuth && !isGoingToSplash) {
        return '/login'; 
      }
    }

    if (tieneCuenta && estaDesbloqueado && (isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToLocalAuth)) {
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
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
  path: '/movie-details',
  name: 'movie-details',
  builder: (context, state) {
    final movie = state.extra as Movie; 
    return MovieDetailsScreen(movie: movie);
  },
),
GoRoute(
  path: '/favorites',
  name: FavoritesScreen.name,
  builder: (context, state) => const FavoritesScreen(),
),
  ],
);