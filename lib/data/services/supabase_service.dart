import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Obtenemos el cliente global de Supabase
  final SupabaseClient _client = Supabase.instance.client;

  /// Registra un nuevo usuario en 2 pasos:
  /// 1. Crea la cuenta en Supabase Auth (Email y Password).
  /// 2. Guarda los datos personales en la tabla pública 'profiles'.
  Future<void> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // --- PASO 1: Registro en Auth ---
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = res.user;

      if (user == null) {
        throw Exception('No se pudo crear el usuario (Auth Error).');
      }

      // --- PASO 2: Guardar datos en la tabla 'profiles' ---
      // Usamos el ID que nos devolvió Auth para vincular los datos
      await _client.from('profiles').insert({
        'id': user.id, // <--- CLAVE: El ID debe coincidir
        ...profileData, // Insertamos nombres, cédula, estado, etc.
        'role': 'user', // Definimos que es un usuario normal (no empresa)
        'created_at': DateTime.now().toIso8601String(),
      });

    } on AuthException catch (e) {
      // Errores específicos de autenticación (ej: email ya existe)
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      // Errores de base de datos (ej: error al guardar perfil)
      throw Exception('Error al guardar perfil: ${e.message}');
    } catch (e) {
      // Cualquier otro error
      throw Exception('Error inesperado: $e');
    }
  }
}