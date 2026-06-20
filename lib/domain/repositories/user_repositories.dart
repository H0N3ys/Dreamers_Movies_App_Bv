import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/database_helper.dart';
import '../entities/user_entities.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<UserEntity?> getCurrentUser() async {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (!isLoggedIn) return null;

      // Recuperamos los datos locales que guardaste en el LoginScreen
      return UserEntity(
        id: prefs.getString('user_id') ?? '',
        email: prefs.getString('user_email') ?? '',
        nombres: prefs.getString('user_nombres'),
        apellidos: prefs.getString('user_apellidos'),
        telefono: prefs.getString('user_telefono'),
        isEmailConfirmed: true, // Lo forzamos a true para local
      );
    }

  Future<UserEntity?> register({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    String? telefono,
  }) async {
    try {
      print('📝 Registrando: $email');

      final result = await _db.registerUser({
        'email': email,
        'password_hash': password,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono ?? '',
      });

      if (result == null) {
        print('❌ Resultado null');
        return null;
      }

      print('✅ Usuario registrado: ${result['email']}');
      return UserEntity.fromJson(result);
    } catch (e) {
      print('❌ Error en register: $e');
      throw Exception('Error al registrar: $e');
    }
  }

  Future<UserEntity?> login(String email, String password) async {
    try {
      final result = await _db.loginUser(email, password);

      if (result == null) return null;

      return UserEntity.fromJson(result);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> logout() async {
    try {
      print('📝 Cerrando sesión local...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Solo borramos la memoria local
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}