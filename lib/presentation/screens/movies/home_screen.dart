import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cinexa',
          style: TextStyle(
            fontFamily: AppTheme.primaryFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout, 
              color: AppColors.secondaryColor,
            ),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              
              await prefs.remove('auth_token');

              if (context.mounted) {
                context.goNamed('login-screen');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a Cinexa!\nAquí se mostrarán las películas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.secondaryFont,
            fontSize: 36,
          ),
        ),
      ),
    );
  }
}