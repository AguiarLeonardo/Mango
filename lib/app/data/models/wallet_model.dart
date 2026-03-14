/// Modelo de datos para la billetera del usuario.
/// Mapea directamente la tabla `wallets` de Supabase.
class WalletModel {
  final double balance;
  final String currency;

  const WalletModel({
    required this.balance,
    required this.currency,
  });

  /// Wallet por defecto para usuarios nuevos sin fila en la tabla `wallets`.
  static const WalletModel empty = WalletModel(balance: 0.0, currency: 'USD');

  /// Factory para parsear una fila de Supabase.
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
    };
  }
}
