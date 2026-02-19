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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isBusinessMode.value ? "Mis Ventas" : "Mis Reservas",
          style: const TextStyle(fontWeight: FontWeight.bold)
        )),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.orange));
        }

        if (controller.ordersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 70, color: Colors.grey[300]),
                const SizedBox(height: 15),
                Text(
                  controller.isBusinessMode.value 
                    ? "Aún no tienes ventas." 
                    : "No tienes reservas activas.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)
                ),
              ],
            ),
          );
        }

        // --- VISTA PARA LA EMPRESA (Lista Sencilla) ---
        if (controller.isBusinessMode.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.ordersList.length,
            itemBuilder: (context, index) {
              final order = controller.ordersList[index];
              final pack = order['packs'] ?? {}; 
              DateTime date = order['created_at'] != null ? DateTime.parse(order['created_at']).toLocal() : DateTime.now();
              final String code = order['code'] ?? order['pickup_code'] ?? '---';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.orange, child: Icon(Icons.store, color: Colors.white)),
                  title: Text("Reserva: $code", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(pack['title'] ?? 'Pack'),
                  trailing: Text(DateFormat('HH:mm').format(date)),
                ),
              );
            }
          );
        }

        // --- VISTA PARA EL CLIENTE (Boletos con Pestañas) ---
        // Filtramos las órdenes activas y el historial para las pestañas
        final activeOrders = controller.ordersList.where((o) => o['status'] == 'pending').toList();
        final pastOrders = controller.ordersList.where((o) => o['status'] != 'pending').toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: const TabBar(
                  indicatorColor: AppColors.orange,
                  labelColor: AppColors.orange,
                  unselectedLabelColor: Colors.grey,
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

  // Generador de lista de tickets
  Widget _buildTicketList(List<dynamic> orders, {required bool isActiveTab}) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isActiveTab ? "No tienes reservas pendientes" : "Tu historial está vacío",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        
        // Extracción segura de datos
        final pack = order['packs'] ?? {}; 
        final business = pack['businesses'] ?? {}; 
        DateTime date = order['created_at'] != null ? DateTime.parse(order['created_at']).toLocal() : DateTime.now();
        final String code = order['code'] ?? order['pickup_code'] ?? '---';
        
        // Manejo del precio
        final double rawPrice = pack['price'] != null ? double.tryParse(pack['price'].toString()) ?? 0.0 : 0.0;
        final String formattedPrice = "${rawPrice.toStringAsFixed(2)} Bs";

        return TicketCard(
          businessName: business['commercial_name'] ?? 'Tienda Local',
          packTitle: pack['title'] ?? 'Pack Reservado',
          price: formattedPrice,
          orderCode: code,
          date: DateFormat('dd MMM, HH:mm').format(date),
          isActive: isActiveTab, // Si estamos en la pestaña activa, es naranja. Si no, gris.
        );
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

  const TicketCard({
    super.key,
    required this.businessName,
    required this.packTitle,
    required this.price,
    required this.orderCode,
    required this.date,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = isActive ? AppColors.orange : Colors.grey.shade400;
    final Color textColor = isActive ? AppColors.darkOlive : Colors.grey.shade500;
    final Color codeColor = isActive ? AppColors.orange : Colors.grey.shade500;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.08 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(), 
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // --- MITAD SUPERIOR: DATOS DEL PACK ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.grey.shade100, 
                ),
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
                          Text(businessName, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          const SizedBox(height: 5),
                          Text(packTitle, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                              Text(price, style: TextStyle(color: mainColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- LÍNEA DIVISORIA PUNTEADA ---
              SizedBox(
                height: 20,
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: DashedLinePainter(color: Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
              ),

              // --- MITAD INFERIOR: CÓDIGO DE RETIRO ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive ? mainColor.withOpacity(0.05) : Colors.grey.shade100,
                ),
                child: Column(
                  children: [
                    Text(
                      isActive ? "CÓDIGO DE RETIRO" : "CÓDIGO CANJEADO / VENCIDO",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      orderCode,
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 6, 
                        color: codeColor,
                        decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isActive)
                      Text(
                        "Muestra este código en el local para retirar tu pack.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
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

// ==========================================
// HERRAMIENTAS DE DIBUJO PARA EL TICKET
// ==========================================
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.addOval(Rect.fromCircle(center: Offset(size.width, size.height * 0.65), radius: 10));
    path.addOval(Rect.fromCircle(center: Offset(0.0, size.height * 0.65), radius: 10));
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
    final paint = Paint()..color = color..strokeWidth = 2;
    while (startX < size.width - 15) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}