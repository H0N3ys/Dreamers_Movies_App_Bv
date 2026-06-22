import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _nombreUsuario = 'Usuario'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    // Recuperamos el nombre que guardaste en el LoginScreen
    final nombre = prefs.getString('user_nombres');
    
    if (nombre != null && nombre.isNotEmpty) {
      setState(() {
        _nombreUsuario = nombre;
      });
    }
  }

  Future<void> _cerrarSesionLocal() async {
    final userRepository = UserRepository();
    await userRepository.logout(); // Limpia SharedPreferences
    
    if (mounted) {
      context.goNamed('login-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/profile'),
            onLongPress: _cerrarSesionLocal,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
                border: Border.all(color: Colors.white38, width: 1.5),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white70, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $_nombreUsuario', // <-- Aquí se muestra el nombre real
                  style: TextStyle(
                    fontFamily: AppTheme.secondaryFont,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Veamos tu película favorita',
                  style: TextStyle(
                    fontFamily: AppTheme.secondaryFont,
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}