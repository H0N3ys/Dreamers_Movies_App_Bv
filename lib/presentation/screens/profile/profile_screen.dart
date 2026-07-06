import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';
import 'package:dreamers_movies_app_bv/domain/entities/user_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/profile/profile_list_item.dart';

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
  
 
  int _currentNavIndex = 3; 

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

  @override
  Widget build(BuildContext context) {
    
    final String nombrePrincipal = _currentUser?.nombres ?? 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.secondaryColor, // El fondo azul marino
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Perfil Real 
                ProfileListItem(
                  title: nombrePrincipal,
                  subtitle: 'Perfil primario',
                  isSelected: true,
                  onTap: () {},
                ),
                
               
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                
                // Perfiles secundarios de demostración
                ProfileListItem(
                  title: 'Adrian',
                  subtitle: 'Perfil secundario',
                  isSelected: false,
                  onTap: () {},
                ),
                
                ProfileListItem(
                  title: 'Saul',
                  subtitle: 'Modo infantil',
                  isSelected: false,
                  onTap: () {},
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                
                // Botón de Agregar
                ProfileListItem(
                  title: 'Agregar perfil',
                  isAddButton: true,
                  onTap: () {
                    // Acción para crear nuevo perfil
                  },
                ),
                
                const Spacer(),
                
             
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await _userRepository.logout();
                      if (context.mounted) context.go('/login');
                    }, 
                    icon: const Icon(Icons.logout, color: Colors.white54), 
                    label: const Text(
                      'Cerrar sesión', 
                      style: TextStyle(color: Colors.white54)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
      ),
      
      // La barra de navegación
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          // Si toca inicio, lo regresamos al Home
          if (index == 0) context.go('/');
          if (index == 1) context.push('/search');
        },
      ),
    );
  }
}