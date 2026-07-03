import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/database_helper.dart';
import '../entities/user_entities.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<UserEntity?> loginWithGoogle() async {
    try {
      // 1. Disparar el flujo nativo de selección de cuenta de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null; 
      }

      // 2. Extraer datos básicos del usuario de Google
      final String email = googleUser.email;
      final String googleId = googleUser.id;
      
      // Separar el nombre completo en nombres y apellidos de manera simple
      final displayName = googleUser.displayName ?? 'Usuario Google';
      final nameParts = displayName.split(' ');
      final String nombres = nameParts.isNotEmpty ? nameParts.first : displayName;
      final String apellidos = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // 3. Mandar los datos recopilados a tu SQLite local
      final localUser = await _dbHelper.authOrRegisterWithGoogle(
        email: email,
        googleId: googleId,
        nombres: nombres,
        apellidos: apellidos,
      );

      // 👇 ESTE ES EL CAMBIO: Convertimos el Map a UserEntity antes de retornarlo
      if (localUser == null) return null;
      return UserEntity.fromJson(localUser);

    } catch (e) {
      print('❌ Error en UserRepository (Google Sign-In): $e');
      throw Exception('No se pudo iniciar sesión con Google: $e');
    }
  
  }

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
      
      // 1. Borramos la memoria local de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
      print('✅ Memoria local SharedPreferences limpia');

      // 2. OBLIGAMOS A GOOGLE A DESCONECTARSE
      // .disconnect() borra por completo el login del dispositivo para esta app
      // y obliga a que la próxima vez solicite elegir cuenta obligatoriamente.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        print('✅ Conexión con cuenta de Google revocada con éxito');
      }

      print('✅ Sesión cerrada completamente');
    } catch (e) {
      print('❌ Error en logout: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}