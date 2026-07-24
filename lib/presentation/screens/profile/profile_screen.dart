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
import 'package:dreamers_movies_app_bv/presentation/widgets/shared/app_refresh_indicator.dart';

class ProfileScreen extends StatefulWidget {
  static const name = 'profile-screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  UserEntity? _currentUser;
  List<Map<String, dynamic>> _profiles = [];
  int? _activeProfileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Limpiamos caché al entrar a la pantalla por si hubo cambios externos
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      final prefs = await SharedPreferences.getInstance();
      final activeProfileId = prefs.getInt('active_profile_id');
      final profiles = await _userRepository.getProfilesForCurrentUser();
      final user = await _userRepository.getCurrentUser();

      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _profiles = profiles;
        _activeProfileId = activeProfileId;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectProfile(int profileId) async {
    if (_activeProfileId == profileId) return;

    final success = await _userRepository.selectProfile(profileId);
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cambiar el perfil')),
      );
      return;
    }

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    await _loadUserProfile();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Perfil cambiado exitosamente')),
    );
  }

  void _handleUserUpdated(UserEntity updatedUser) {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    _loadUserProfile();
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
          backgroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.white12),
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            splashRadius: 24,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSettingsScreen(
                    currentUser: _currentUser,
                    onUserUpdated: _handleUserUpdated,
                  ),
                ),
              );
              _loadUserProfile();
            },
          ),
        ],
      ),

      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: _loadUserProfile,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        'SELECCIONAR PERFIL',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Lista de perfiles cargados
                    ..._profiles.map((profile) {
                      final profileId = profile['id_perfil'] as int;
                      final profileName = profile['nombre_perfil']?.toString() ?? 'Perfil';
                      final avatarUrl = profile['avatar_url']?.toString();
                      final isSelected = _activeProfileId == profileId;

                      return ProfileListItem(
                        title: profileName,
                        subtitle: isSelected
                            ? 'Seleccionado (Toca para detalles)'
                            : 'Toca para activar este perfil',
                        isSelected: isSelected,
                        avatarUrl: avatarUrl,
                        onTap: isSelected
                            ? () async {
                                await context.pushNamed('user-details-screen');
                                _loadUserProfile();
                              }
                            : () => _selectProfile(profileId),
                      );
                    }),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Divider(color: Colors.white12, height: 1),
                    ),

                    ProfileListItem(
                      title: 'Administrar o agregar perfil',
                      isAddButton: true,
                      onTap: () async {
                        await context.pushNamed(ProfilePickerScreen.name);
                        _loadUserProfile();
                      },
                    ),

                    const SizedBox(height: 40),

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
        ),
      ),

      // La barra de navegación
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}