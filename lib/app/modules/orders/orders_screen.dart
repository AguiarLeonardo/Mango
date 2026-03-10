import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'orders_controller.dart';
import '../../core/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  final OrdersController controller = Get.put(OrdersController());

  OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: Obx(() => Text(
            controller.isBusinessMode.value ? "Mis Ventas" : "Mis Reservas",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textBlack, fontWeight: FontWeight.bold))),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.backgroundCream,
        elevation: 0,
      ),
      floatingActionButton: Obx(() {
        if (controller.isBusinessMode.value) {
          return FloatingActionButton.extended(
            onPressed: () => _showValidationDialog(),
            backgroundColor: AppTheme.accentOrange,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text("Validar Entrega",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          );
        }
        return const SizedBox.shrink();
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        if (controller.ordersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long,
                    size: 70, color: AppTheme.disabledIcon.withOpacity(0.5)),
                const SizedBox(height: 15),
                Text(
                    controller.isBusinessMode.value
                        ? "Aún no tienes ventas."
                        : "No tienes reservas activas.",
                    style: TextStyle(
                        color: AppTheme.textBlack.withOpacity(0.6),
                        fontSize: 16)),
              ],
            ),
          );
        }

        if (controller.isBusinessMode.value) {
          return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.ordersList.length,
              itemBuilder: (context, index) {
                final order = controller.ordersList[index];
                final pack = order['packs'] ?? {};
                DateTime date = order['created_at'] != null
                    ? DateTime.parse(order['created_at']).toLocal()
                    : DateTime.now();
                final String code =
                    order['code'] ?? order['pickup_code'] ?? '---';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.store,
                            color: AppTheme.primaryGreen)),
                    title: Text("Reserva: $code",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textBlack)),
                    subtitle: Text(pack['title'] ?? 'Pack',
                        style: TextStyle(
                            color: AppTheme.textBlack.withOpacity(0.7))),
                    trailing: Text(DateFormat('HH:mm').format(date),
                        style: const TextStyle(color: AppTheme.textBlack)),
                  ),
                );
              });
        }

        final activeOrders = controller.ordersList
            .where((o) => o['status'] == 'pending')
            .toList();
        final pastOrders = controller.ordersList
            .where((o) => o['status'] != 'pending')
            .toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: AppTheme.backgroundCream,
                child: const TabBar(
                  indicatorColor: AppTheme.accentOrange,
                  labelColor: AppTheme.accentOrange,
                  unselectedLabelColor: AppTheme.disabledIcon,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: "ACTIVAS"),
                    Tab(text: "HISTORIAL"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTicketList(activeOrders, isActiveTab: true),
                    _buildTicketList(pastOrders, isActiveTab: false),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTicketList(List<dynamic> orders, {required bool isActiveTab}) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isActiveTab
              ? "No tienes reservas pendientes"
              : "Tu historial está vacío",
          style: TextStyle(color: AppTheme.textBlack.withOpacity(0.5)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final orderData = orders[index];
        final pack = orderData['packs'] ?? {};
        final business = pack['businesses'] ?? {};
        DateTime date = orderData['created_at'] != null
            ? DateTime.parse(orderData['created_at']).toLocal()
            : DateTime.now();
        final String code =
            orderData['code'] ?? orderData['pickup_code'] ?? '---';

        final double rawPrice = pack['price'] != null
            ? double.tryParse(pack['price'].toString()) ?? 0.0
            : 0.0;
        final String formattedPrice = "${rawPrice.toStringAsFixed(2)} Bs";

        // IDs para calificación
        final String packId = orderData['pack_id'] ?? pack['id'] ?? '';
        final String businessId =
            orderData['business_id'] ?? business['id'] ?? '';
        final String orderId = orderData['id'] ?? '';

        // Determinar lógica canCancel (US 2)
        // pickup_start puede ser time-only ("18:00:00") o ISO-8601 completo.
        // Si es time-only, DateTime.parse crea 1970-01-01 → siempre en el pasado.
        // Combinamos con la fecha de la orden para obtener un DateTime válido.
        DateTime pickupStart;
        final rawPickup = pack['pickup_start'];
        if (rawPickup != null) {
          final parsed = DateTime.tryParse(rawPickup.toString());
          if (parsed != null && parsed.year >= 2000) {
            pickupStart = parsed.toLocal();
          } else {
            // Time-only: extraer horas y minutos, combinar con fecha de la orden
            final timeParts = rawPickup.toString().split(':');
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute =
                timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
            pickupStart =
                DateTime(date.year, date.month, date.day, hour, minute);
          }
        } else {
          pickupStart =
              DateTime.now().add(const Duration(hours: 3)); // Fallback seguro
        }

        final bool canCancel = isActiveTab &&
            DateTime.now()
                .isBefore(pickupStart.subtract(const Duration(hours: 2)));

        return TicketCard(
          businessName: business['commercial_name'] ?? 'Tienda Local',
          packTitle: pack['title'] ?? 'Pack Reservado',
          price: formattedPrice,
          orderCode: code,
          date: DateFormat('dd MMM, HH:mm').format(date),
          isActive: isActiveTab,
          canCancel: canCancel,
          onCancelTap: canCancel
              ? () => _confirmCancelOrder(
                  orderId,
                  pack['pickup_end'] != null
                      ? DateTime.parse(pack['pickup_end']).toLocal()
                      : DateTime.now())
              : null,
          onRateTap: () =>
              _showRatingBottomSheet(Get.context!, businessId, packId),
        );
      },
    );
  }

  // ✅ NUEVA FUNCIÓN: CONFIRMAR CANCELACIÓN (US 2)
  void _confirmCancelOrder(String orderId, DateTime pickupEnd) {
    Get.defaultDialog(
      title: "Cancelar Reserva",
      titleStyle: const TextStyle(
        color: AppTheme.textBlack,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      content: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          "¿Estás seguro de que quieres cancelar este pack? El importe será devuelto a tu método de pago original.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ),
      textCancel: "Volver",
      cancelTextColor: AppTheme.textBlack,
      textConfirm: "Sí, Cancelar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back(); // Cierra el modal de confirmación
        controller.cancelMyOrder(orderId, pickupEnd);
      },
    );
  }

  // ✅ NUEVA FUNCIÓN: VENTANITA DE ESTRELLITAS (BOTTOM SHEET)
  void _showRatingBottomSheet(
      BuildContext context, String businessId, String packId) {
    int selectedStars = 5;
    TextEditingController commentController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return Container(
          padding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("Califica tu experiencia",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack)),
                const SizedBox(height: 5),
                Text("¿Qué te pareció el pack salvado?",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 20),

                // LAS ESTRELLITAS INTERACTIVAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedStars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 45,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedStars = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 15),

                // CAMPO PARA COMENTARIO
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Escribe un breve comentario (opcional)...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 25),

                // BOTÓN DE ENVIAR
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.submitReview(
                        businessId: businessId,
                        packId: packId,
                        rating: selectedStars,
                        comment: commentController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("ENVIAR RESEÑA",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  // ✅ NUEVA FUNCIÓN: DIÁLOGO DE VALIDACIÓN DE ENTREGA
  void _showValidationDialog() {
    final TextEditingController codeController = TextEditingController();

    Get.defaultDialog(
      title: "Validar Entrega",
      titleStyle: const TextStyle(
          color: AppTheme.textBlack, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: "Ej. MNG-4X9B",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryGreen)),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      textCancel: "Cancelar",
      cancelTextColor: AppTheme.textBlack,
      textConfirm: "Confirmar",
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.primaryGreen,
      onConfirm: () {
        final code = codeController.text.trim();
        if (code.isNotEmpty) {
          Get.back(); // Cerrar diálogo
          controller.validateOrderCode(code); // Llamada al método US 1
        } else {
          Get.snackbar("Error", "Debes ingresar un código válido",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }
}

// ==========================================
// WIDGET MÁGICO: EL BOLETO FÍSICO (TICKET)
// ==========================================
class TicketCard extends StatelessWidget {
  final String businessName;
  final String packTitle;
  final String price;
  final String orderCode;
  final String date;
  final bool isActive;
  final bool canCancel; // ✅ NUEVO PARAMETRO
  final VoidCallback? onCancelTap; // ✅ NUEVA FUNCIÓN DE CANCELACIÓN
  final VoidCallback? onRateTap;

  const TicketCard({
    super.key,
    required this.businessName,
    required this.packTitle,
    required this.price,
    required this.orderCode,
    required this.date,
    required this.isActive,
    this.canCancel = false,
    this.onCancelTap,
    this.onRateTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor =
        isActive ? AppTheme.primaryGreen : AppTheme.disabledIcon;
    final Color textColor =
        isActive ? AppTheme.textBlack : AppTheme.disabledIcon;
    final Color codeColor =
        isActive ? AppTheme.accentOrange : AppTheme.disabledIcon;
    final Color backgroundColor =
        isActive ? Colors.white : AppTheme.disabledBackground;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.06 : 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          color: backgroundColor,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.storefront, color: mainColor, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(businessName,
                              style: TextStyle(
                                  color: AppTheme.textBlack.withOpacity(0.6),
                                  fontSize: 14)),
                          const SizedBox(height: 5),
                          Text(packTitle,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(date,
                                  style: TextStyle(
                                      color:
                                          AppTheme.textBlack.withOpacity(0.5),
                                      fontSize: 13)),
                              Text(price,
                                  style: TextStyle(
                                      color: mainColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: DashedLinePainter(
                            color: AppTheme.textBlack.withOpacity(0.15)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive
                      ? mainColor.withOpacity(0.04)
                      : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      isActive
                          ? "CÓDIGO DE RETIRO"
                          : "CÓDIGO CANJEADO / VENCIDO",
                      style: TextStyle(
                          color: AppTheme.textBlack.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      orderCode,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: codeColor,
                        decoration: isActive
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isActive)
                      Text(
                        "Muestra este código en el local para retirar tu pack.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textBlack.withOpacity(0.7),
                            fontSize: 13),
                      ),

                    // ✅ AQUÍ APARECE EL BOTÓN DE CALIFICAR SI EL TICKET ESTÁ EN EL HISTORIAL
                    if (!isActive && onRateTap != null) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: onRateTap,
                          icon: const Icon(Icons.star_border,
                              color: AppTheme.accentOrange),
                          label: const Text("Calificar Pack",
                              style: TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppTheme.accentOrange.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],

                    // ✅ LÓGICA DE CANCELACIÓN DE ORDEN (US 2)
                    if (isActive) ...[
                      const SizedBox(height: 15),
                      if (canCancel)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: onCancelTap,
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.orange),
                            label: const Text("Cancelar Reserva",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.orange.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_clock,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                "Periodo de cancelación cerrado",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... EL RESTO DEL CÓDIGO (TicketClipper y DashedLinePainter) SE MANTIENE EXACTAMENTE IGUAL ...
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.addOval(Rect.fromCircle(
        center: Offset(size.width, size.height * 0.65), radius: 10));
    path.addOval(
        Rect.fromCircle(center: Offset(0.0, size.height * 0.65), radius: 10));
    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 4, startX = 15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    while (startX < size.width - 15) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
