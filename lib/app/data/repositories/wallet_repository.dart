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

  /// Obtiene la billetera del usuario autenticado leyendo el campo `wallet_balance`
  /// desde la tabla `users` o `businesses`.
  Future<WalletModel> fetchWallet() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const WalletException('Usuario no autenticado.');
      }

      // 1. Validar primero si es un usuario normal
      final userData = await _client
          .from('users')
          .select('wallet_balance')
          .eq('id', userId)
          .maybeSingle();

      if (userData != null) {
        return WalletModel(
          balance: (userData['wallet_balance'] as num?)?.toDouble() ?? 0.0,
          currency: 'USD',
        );
      }

      // 2. Si no es usuario, buscar en tabla de negocios (businesses)
      final businessData = await _client
          .from('businesses')
          .select('wallet_balance')
          .eq('id', userId)
          .maybeSingle();

      if (businessData != null) {
        return WalletModel(
          balance: (businessData['wallet_balance'] as num?)?.toDouble() ?? 0.0,
          currency: 'USD',
        );
      }

      // Si no existe ni en users ni en businesses (caso extraño)
      return WalletModel.empty;
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletException('Error al obtener la billetera: $e');
    }
  }

  /// Obtiene el historial de transacciones del usuario autenticado
  /// desde la tabla `wallet_transactions`.
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const WalletException('Usuario no autenticado.');
      }

      final response = await _client
          .from('wallet_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletException('Error al obtener las transacciones: $e');
    }
  }
}
