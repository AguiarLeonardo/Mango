import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Excepción tipada para UserRepository ───
class UserRepositoryException implements Exception {
  final String message;
  const UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}

/// Repositorio que maneja las operaciones sobre la tabla `users`.
/// Utiliza el SupabaseClient genérico del proyecto para consistencia.
class UserRepository {
  final SupabaseClient _client;

  UserRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Actualiza el `fcm_token` del usuario autenticado en la tabla `users`.
  Future<void> updateFcmToken(String token) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const UserRepositoryException(
            'No hay usuario autenticado para guardar el token.');
      }

      await _client
          .from('users')
          .update({'fcm_token': token}).eq('id', userId);
    } catch (e) {
      if (e is UserRepositoryException) rethrow;
      throw UserRepositoryException('Error al actualizar FCM Token: $e');
    }
  }
}
