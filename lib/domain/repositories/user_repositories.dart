
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/user_entities.dart';

class UserRepository {
  Future<UserEntity?> getCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    
    final session = Supabase.instance.client.auth.currentSession;
    
    final metadata = user.userMetadata ?? {};
    
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      nombres: metadata['nombres'] as String?,
      apellidos: metadata['apellidos'] as String?,
      telefono: metadata['telefono'] as String?,
      accessToken: session?.accessToken,
      isEmailConfirmed: user.confirmedAt != null,
    );
  }

  bool isAuthenticated() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    await clearUserFromPrefs();
  }

  Future<void> updateProfile({
    String? nombres,
    String? apellidos,
    String? telefono,
    String? avatarUrl,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final Map<String, dynamic> updates = {};
    if (nombres != null) updates['nombres'] = nombres;
    if (apellidos != null) updates['apellidos'] = apellidos;
    if (telefono != null) updates['telefono'] = telefono;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: updates),
      );
    }
  }

  Future<void> saveUserToPrefs(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_nombres', user.nombres ?? '');
    await prefs.setString('user_apellidos', user.apellidos ?? '');
    await prefs.setString('user_telefono', user.telefono ?? '');
    await prefs.setBool('is_logged_in', true);
    if (user.accessToken != null) {
      await prefs.setString('auth_token', user.accessToken!);
    }
  }

  Future<UserEntity?> getUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;
    
    return UserEntity(
      id: id,
      email: prefs.getString('user_email') ?? '',
      nombres: prefs.getString('user_nombres'),
      apellidos: prefs.getString('user_apellidos'),
      telefono: prefs.getString('user_telefono'),
      accessToken: prefs.getString('auth_token'),
      isEmailConfirmed: true,
    );
  }

  Future<void> clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_nombres');
    await prefs.remove('user_apellidos');
    await prefs.remove('user_telefono');
    await prefs.remove('auth_token');
    await prefs.setBool('is_logged_in', false);
  }
}