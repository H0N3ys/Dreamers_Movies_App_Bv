// lib/domain/repositories/user_repositories.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/database_helper.dart';
import '../entities/user_entities.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();

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

  // ... resto de métodos
}