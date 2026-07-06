import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseHelper {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Correo o contraseña incorrectos';
        case 'user already registered':
          return 'Este correo ya está registrado';
        case 'password should be at least 6 characters':
          return 'La contraseña debe tener al menos 6 caracteres';
        case 'email not confirmed':
          return 'Por favor verifica tu correo electrónico';
        default:
          return error.message;
      }
    }
    return 'Error de conexión: $error';
  }
}