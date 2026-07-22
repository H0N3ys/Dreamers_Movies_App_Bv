import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';
import 'package:dreamers_movies_app_bv/domain/entities/user_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/profile/profile_list_item.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/profile/profile_settings_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/profile/profile_picker_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const name = 'profile-screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  UserEntity? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _userRepository.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleUserUpdated(UserEntity updatedUser) {
    setState(() {
      _currentUser = updatedUser;
      _isLoading = false;
    });
  }

  Future<void> _executeLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await _userRepository.logout();

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              AppColors.secondaryColor, // Fondo oscuro para que combine
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.white12), // Borde sutil
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            '¿Estás seguro que deseas cerrar tu sesión actual?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Retorna 'false'
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Retorna 'true'
              child: const Text(
                'Sí, salir',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _executeLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombrePrincipal = _currentUser?.nombres ?? 'Usuario';
    final String alias =
        _currentUser?.alias ?? _currentUser?.nombres ?? 'usuario';
    final String avatarPath = _currentUser?.avatarUrl ?? '';

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            splashRadius: 24,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // 👇 Asegúrate de que NO haya un "const" antes de ProfileSettingsScreen
                  builder: (context) => ProfileSettingsScreen(
                    currentUser: _currentUser,
                    onUserUpdated: _handleUserUpdated,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Perfil Real
                  ProfileListItem(
                    title: nombrePrincipal,
                    subtitle: '@$alias',
                    isSelected: true,
                    avatarUrl: avatarPath,
                    onTap: () {
                      context.pushNamed('user-details-screen');
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: Colors.white12, height: 1),
                  ),

                  ProfileListItem(
                    title: 'Agregar perfil',
                    isAddButton: true,
                    onTap: () => context.pushNamed(ProfilePickerScreen.name),
                  ),

                  const Spacer(),

                  Center(
                    child: TextButton.icon(
                      onPressed: _showLogoutConfirmation,
                      icon: const Icon(Icons.logout, color: Colors.white54),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),

      // La barra de navegación
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}
