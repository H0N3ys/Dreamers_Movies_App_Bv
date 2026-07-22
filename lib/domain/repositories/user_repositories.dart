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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      final String email = googleUser.email;
      final String googleId = googleUser.id;

      final displayName = googleUser.displayName ?? 'Usuario Google';
      final nameParts = displayName.split(' ');
      final String nombres = nameParts.isNotEmpty
          ? nameParts.first
          : displayName;
      final String apellidos = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final localUser = await _dbHelper.authOrRegisterWithGoogle(
        email: email,
        googleId: googleId,
        nombres: nombres,
        apellidos: apellidos,
      );

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

    return UserEntity(
      id: prefs.getString('user_id') ?? '',
      email: prefs.getString('user_email') ?? '',
      nombres: prefs.getString('user_nombres') ?? 'Usuario',
      apellidos: prefs.getString('user_apellidos'),
      telefono: prefs.getString('user_telefono'),
      alias:
          prefs.getString('user_apodo') ??
          prefs.getString('user_nombres') ??
          'Usuario',
      avatarUrl:
          prefs.getString('active_profile_avatar') ??
          prefs.getString('user_avatar'),
      isEmailConfirmed: true,
    );
  }

  Future<List<Map<String, dynamic>>> getProfilesForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) return [];

    final profiles = await _dbHelper.getProfilesByUser(
      int.tryParse(userId) ?? 0,
    );
    if (profiles.isEmpty) {
      final fallbackProfileId = await _dbHelper.createProfileForUser(
        userId: int.tryParse(userId) ?? 0,
        nombrePerfil: prefs.getString('user_nombres')?.isNotEmpty == true
            ? prefs.getString('user_nombres')!
            : 'Principal',
      );
      if (fallbackProfileId != null) {
        await prefs.setInt('active_profile_id', fallbackProfileId);
        await prefs.setString(
          'active_profile_name',
          prefs.getString('user_nombres') ?? 'Principal',
        );
      }
      return await _dbHelper.getProfilesByUser(int.tryParse(userId) ?? 0);
    }

    return profiles;
  }

  Future<int?> ensureActiveProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final parsedUserId = int.tryParse(userId) ?? 0;
    if (parsedUserId <= 0) return null;

    final profiles = await _dbHelper.getProfilesByUser(parsedUserId);
    if (profiles.isEmpty) {
      final createdProfileId = await _dbHelper.createProfileForUser(
        userId: parsedUserId,
        nombrePerfil: 'Principal',
      );
      if (createdProfileId == null) return null;
      await prefs.setInt('active_profile_id', createdProfileId);
      await prefs.setString('active_profile_name', 'Principal');
      await prefs.setString('active_profile_avatar', '');
      return createdProfileId;
    }

    final activeProfileId = prefs.getInt('active_profile_id');
    final selectedProfile = activeProfileId != null
        ? profiles.firstWhere(
            (profile) => (profile['id_perfil'] as int?) == activeProfileId,
            orElse: () => profiles.first,
          )
        : profiles.first;

    final profileId = selectedProfile['id_perfil'] as int;
    await prefs.setInt('active_profile_id', profileId);
    await prefs.setString(
      'active_profile_name',
      (selectedProfile['nombre_perfil'] ?? 'Principal').toString(),
    );
    await prefs.setString(
      'active_profile_avatar',
      (selectedProfile['avatar_url'] ?? '').toString(),
    );
    return profileId;
  }

  Future<bool> selectProfile(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final profile = await _dbHelper.getProfileById(profileId);
    if (profile == null) return false;

    await prefs.setInt('active_profile_id', profileId);
    await prefs.setString(
      'active_profile_name',
      profile['nombre_perfil']?.toString() ?? 'Principal',
    );
    await prefs.setString(
      'active_profile_avatar',
      profile['avatar_url']?.toString() ?? '',
    );
    return true;
  }

  Future<int?> createProfile(String userId, String profileName) async {
    final parsedUserId = int.tryParse(userId) ?? 0;
    if (parsedUserId <= 0) return null;

    final profileId = await _dbHelper.createProfileForUser(
      userId: parsedUserId,
      nombrePerfil: profileName,
    );

    if (profileId != null) {
      await selectProfile(profileId);
    }

    return profileId;
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

  // Actualizar Nombre, Apellidos y Teléfono
  Future<bool> updateProfileInfo({
    required String userId,
    required String nombres,
    required String apellidos,
    required String alias,
    String? telefono,
  }) async {
    try {
      final db = await _db.database;
      final success = await db.update(
        'usuario',
        {
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono ?? '',
          'apodo': alias,
        },
        where: 'id_usuario = ?',
        whereArgs: [int.parse(userId)],
      );

      if (success > 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_nombres', nombres);
        await prefs.setString('user_apellidos', apellidos);
        await prefs.setString('user_apodo', alias);
        if (telefono != null) await prefs.setString('user_telefono', telefono);
      }
      return success > 0;
    } catch (e) {
      print('❌ Error en updateProfileInfo: $e');
      return false;
    }
  }

  // Actualizar la ruta local de la foto de perfil del perfil activo
  Future<bool> updateAvatar(String userId, String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentProfileId = prefs.getInt('active_profile_id');

      if (currentProfileId == null || currentProfileId <= 0) {
        final profiles = await _dbHelper.getProfilesByUser(
          int.tryParse(userId) ?? 0,
        );
        if (profiles.isEmpty) return false;
        final fallbackProfileId = profiles.first['id_perfil'] as int;
        await prefs.setInt('active_profile_id', fallbackProfileId);
      }

      final activeProfileId = prefs.getInt('active_profile_id');
      if (activeProfileId == null) return false;

      final success = await _dbHelper.updateProfileAvatarById(
        profileId: activeProfileId,
        avatarPath: imagePath,
      );

      if (success) {
        await prefs.setString('user_avatar', imagePath);
        await prefs.setString('active_profile_avatar', imagePath);
      }

      return success;
    } catch (e) {
      print('❌ Error en updateAvatar: $e');
      return false;
    }
  }

  // Cambiar contraseña
  Future<bool> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final db = await _db.database;
      final user = await db.query(
        'usuario',
        where: 'id_usuario = ? AND password_hash = ?',
        whereArgs: [int.parse(userId), currentPassword],
      );

      if (user.isEmpty) {
        return false;
      }

      final updated = await db.update(
        'usuario',
        {'password_hash': newPassword},
        where: 'id_usuario = ?',
        whereArgs: [int.parse(userId)],
      );

      return updated > 0;
    } catch (e) {
      print('❌ Error en updateUserPassword: $e');
      return false;
    }
  }
}
