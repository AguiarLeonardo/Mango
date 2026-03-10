import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/order_model.dart';
import 'business_orders_controller.dart';

class BusinessOrdersScreen extends GetView<BusinessOrdersController> {
  const BusinessOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold no es estrictamente necesario aquí si está dentro del IndexedStack,
    // pero aporta un color de fondo base limpio para la pestaña.
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: SafeArea(
        child: Column(
          children: [
            // ─── CABECERA DE VALIDACIÓN ESPACIOSA ───
            _buildValidationHeader(),

            // ─── LISTA DE PEDIDOS PENDIENTES ───
            Expanded(
              child: _buildPendingOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CABECERA DE VALIDACIÓN DE CÓDIGO ───
  Widget _buildValidationHeader() {
    final TextEditingController codeController = TextEditingController();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Validar Entrega",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textBlack,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Ingresa el código proporcionado por el cliente.",
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textBlack.withAlpha(150),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Ej. MNG-4X9",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    prefixIcon:
                        const Icon(Icons.qr_code_2_rounded, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppTheme.primaryGreen, width: 2),
                    ),
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: controller.isValidating.value
                          ? null
                          : () {
                              // Ocultamos el teclado al confirmar
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.confirmPickup(codeController.text);
                              codeController.clear();
                            },
                      child: controller.isValidating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "Confirmar",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── LISTA DE ÓRDENES PENDIENTES ───
  Widget _buildPendingOrdersList() {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingOrdersList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        );
      }

      if (controller.pendingOrdersList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 60,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sin Pedidos Pendientes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "No hay clientes esperando retirar packs.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textBlack.withAlpha(150),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => controller.fetchPendingOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.pendingOrdersList.length,
          itemBuilder: (context, index) {
            final order = controller.pendingOrdersList[index];
            return _OrderCard(order: order);
          },
        ),
      );
    });
  }
}

// ─── TARJETA DE ORDEN PENDIENTE ───
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Permitir al usuario copiar el código o ver detalles futuros
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Imagen del Pack
                  _buildPackImage(),
                  const SizedBox(width: 16),
                  // Detalles
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.packTitle ?? 'Mystery Pack',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.textBlack,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildBadge(
                          icon: Icons.qr_code_2_rounded,
                          text: order
                              .code, // Corregido Warning (order.code asume puede ser no nulo según lint)
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Pedido el ${DateFormat('dd MMM, HH:mm').format(order.createdAt)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── IMAGEN MINIATURA DEL PACK ───
  Widget _buildPackImage() {
    final hasImage =
        order.packImageUrl != null && order.packImageUrl!.isNotEmpty;

    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasImage
            ? Image.network(
                order.packImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.grey,
                  size: 30,
                ),
              )
            : const Icon(
                Icons.restaurant_rounded,
                color: Colors.grey,
                size: 30,
              ),
      ),
    );
  }

  // ─── BADGE (PIZZA LABEL) ───
  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1, // Excelente para códigos
            ),
          ),
        ],
      ),
    );
  }
}
