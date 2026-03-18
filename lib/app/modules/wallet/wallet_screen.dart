import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Mi Billetera'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // 💳 TARJETA PRINCIPAL DE SALDO
              // ═══════════════════════════════════════
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF66BB6A), // Verde más vivo
                      Color(0xFF388E3C), // Verde oscuro
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Saldo Disponible',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.formattedBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.currency.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ─── BOTONES RECARGAR / RETIRAR ───
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Recargar',
                            color: Colors.white,
                            textColor: const Color(0xFF388E3C),
                            onTap: controller.topUp,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Retirar',
                            color: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                            onTap: controller.withdraw,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════
              // 📜 ÚLTIMOS MOVIMIENTOS
              // ═══════════════════════════════════════
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Últimos Movimientos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textBlack,
                  ),
                ),
              ),

              Obx(() {
                if (controller.transactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long,
                              size: 60,
                              color: AppTheme.disabledIcon.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no tienes movimientos\nen tu billetera.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.transactions.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade200, height: 1),
                  itemBuilder: (context, index) {
                    final tx = controller.transactions[index];
                    final String type =
                        tx['transaction_type']?.toString() ?? 'unknown';
                    final double amount =
                        (tx['amount'] as num?)?.toDouble() ?? 0;
                    final String description =
                        tx['description']?.toString() ?? 'Movimiento';
                    final bool isCredit = type == 'credit';

                    // Formatear fecha
                    String dateStr = '';
                    if (tx['created_at'] != null) {
                      final dt = DateTime.tryParse(
                          tx['created_at'].toString());
                      if (dt != null) {
                        final local = dt.toLocal();
                        dateStr =
                            '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
                      }
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? AppTheme.primaryGreen.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isCredit
                              ? AppTheme.primaryGreen
                              : Colors.redAccent,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        dateStr,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                      trailing: Text(
                        '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isCredit
                              ? AppTheme.primaryGreen
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // ─── Widget reutilizable para botones de acción ───
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
