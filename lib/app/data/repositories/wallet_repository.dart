import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';

// ─── Excepción tipada para errores reales de red/permisos ───
class WalletException implements Exception {
  final String message;
  const WalletException(this.message);

  @override
  String toString() => 'WalletException: $message';
}

/// Repositorio que encapsula las llamadas a la tabla `wallets` en Supabase.
class WalletRepository {
  final SupabaseClient _client;

  WalletRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Obtiene la billetera del usuario autenticado.
  ///
  /// - Si el usuario no tiene fila en `wallets`, retorna [WalletModel.empty]
  ///   (graceful degradation — no lanza excepción).
  /// - Solo lanza [WalletException] ante errores reales de red o permisos.
  Future<WalletModel> fetchWallet() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const WalletException('Usuario no autenticado.');
      }

      final data = await _client
          .from('wallets')
          .select('balance, currency')
          .eq('user_id', userId)
          .maybeSingle();

      // Graceful degradation: usuario nuevo sin wallet → balance 0
      if (data == null) {
        return WalletModel.empty;
      }

      return WalletModel.fromJson(data);
    } on WalletException {
      rethrow; // Re-lanzamos nuestras propias excepciones tipadas
    } catch (e) {
      // Cualquier otro error (red, permisos, PostgrestException, etc.)
      throw WalletException('Error al obtener la billetera: $e');
    }
  }
}
