import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/favorites_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/errors/CinexaAnimatedLogo_widget.dart';
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
import 'package:dreamers_movies_app_bv/presentation/screens/movies/saved_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/profile/user_details_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/profile/profile_picker_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/movies/actor_details_screen.dart';

// Importa tu nueva pantalla de error y el archivo donde está tu logo animado (Ajusta la ruta si la guardaste en otra carpeta)
import 'package:dreamers_movies_app_bv/presentation/screens/cinexa_error_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  errorBuilder: (context, state) => const CinexaErrorScreen(
    errorType: CinexaErrorType.notFound404,
    title: 'Pantalla no encontrada',
    message:
        'Parece que te saliste de la sala. Esta sección no existe en Cinexa.',
  ),

  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final tieneCuenta = prefs.getBool('is_logged_in') ?? false;
    final estaDesbloqueado = prefs.getBool('session_unlocked') ?? false;
    final activeProfileId = prefs.getInt('active_profile_id');

    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation == '/register';
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToLocalAuth = state.matchedLocation == '/local-auth';
    final isGoingToProfilePicker = state.matchedLocation == '/profile-picker';

    // Agregamos las rutas de error aquí para que el redirect no las bloquee si llegan a saltar
    final isGoingToError =
        state.matchedLocation.startsWith('/error-') ||
        state.matchedLocation == '/no-connection';

    if (!tieneCuenta &&
        !isGoingToLogin &&
        !isGoingToRegister &&
        !isGoingToSplash &&
        !isGoingToError) {
      return '/login';
    }

    if (tieneCuenta && !estaDesbloqueado) {
      if (!isGoingToLogin &&
          !isGoingToLocalAuth &&
          !isGoingToSplash &&
          !isGoingToError) {
        return '/login';
      }
    }

    if (tieneCuenta && estaDesbloqueado && activeProfileId == null && !isGoingToProfilePicker) {
      return '/profile-picker';
    }

    if (tieneCuenta &&
        estaDesbloqueado &&
        activeProfileId != null &&
        isGoingToProfilePicker) {
      return '/';
    }

    if (tieneCuenta &&
        estaDesbloqueado &&
        (isGoingToLogin ||
            isGoingToRegister ||
            isGoingToSplash ||
            isGoingToLocalAuth)) {
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
      path: '/user-details-screen',
      name: UserDetailsScreen.name,
      builder: (context, state) => const UserDetailsScreen(),
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
      path: '/profile-picker',
      name: ProfilePickerScreen.name,
      builder: (context, state) => const ProfilePickerScreen(),
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
      path: '/actor-details',
      name: ActorDetailsScreen.name,
      builder: (context, state) {
        final actor = state.extra as Map<String, dynamic>;
        return ActorDetailsScreen(actor: actor);
      },
    ),
    GoRoute(
      path: '/favorites',
      name: FavoritesScreen.name,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/saved',
      name: SavedScreen.name,
      builder: (context, state) => const SavedScreen(),
    ),

    // --- NUEVAS RUTAS DE ERROR DE CINEXA ---
    GoRoute(
      path: '/error-404',
      builder: (context, state) => const CinexaErrorScreen(
        errorType: CinexaErrorType.notFound404,
        title: 'Película no encontrada',
        message:
            'Parece que esta cinta se perdió en el archivo. Intenta buscar otro título.',
      ),
    ),
    GoRoute(
      path: '/no-connection',
      builder: (context, state) => const CinexaErrorScreen(
        errorType: CinexaErrorType.noConnection,
        title: 'Sin conexión a internet',
        message:
            'No podemos conectar con la taquilla. Revisa tu wifi o datos móviles.',
      ),
    ),
    GoRoute(
      path: '/error-500',
      builder: (context, state) => const CinexaErrorScreen(
        errorType: CinexaErrorType.server500,
        title: 'Error del servidor',
        message:
            'Nuestro proyecto se atascó. Estamos trabajando para solucionarlo pronto.',
      ),
    ),
  ],
);
