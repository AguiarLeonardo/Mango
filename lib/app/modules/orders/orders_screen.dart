import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'orders_controller.dart';
import '../../core/theme/app_theme.dart'; // Tu Tema Global

class OrdersScreen extends StatelessWidget {
  final OrdersController controller = Get.put(OrdersController());

  OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream, // Fondo Crema del Manual
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isBusinessMode.value ? "Mis Ventas" : "Mis Reservas",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryGreen, 
            fontWeight: FontWeight.bold
          )
        )),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.backgroundCream, // Fundido con el fondo
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        if (controller.ordersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 70, color: AppTheme.disabledIcon.withOpacity(0.5)),
                const SizedBox(height: 15),
                Text(
                  controller.isBusinessMode.value 
                    ? "Aún no tienes ventas." 
                    : "No tienes reservas activas.",
                  style: TextStyle(color: AppTheme.textBlack.withOpacity(0.6), fontSize: 16)
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
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Icon(Icons.store, color: AppTheme.primaryGreen)
                  ),
                  title: Text("Reserva: $code", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
                  subtitle: Text(pack['title'] ?? 'Pack', style: TextStyle(color: AppTheme.textBlack.withOpacity(0.7))),
                  trailing: Text(DateFormat('HH:mm').format(date), style: const TextStyle(color: AppTheme.textBlack)),
                ),
              );
            }
          );
        }

        // --- VISTA PARA EL CLIENTE (Boletos con Pestañas) ---
        final activeOrders = controller.ordersList.where((o) => o['status'] == 'pending').toList();
        final pastOrders = controller.ordersList.where((o) => o['status'] != 'pending').toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: AppTheme.backgroundCream,
                child: const TabBar(
                  indicatorColor: AppTheme.accentOrange, // Naranja para la pestaña seleccionada
                  labelColor: AppTheme.accentOrange,
                  unselectedLabelColor: AppTheme.disabledIcon, // Gris para la inactiva
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

  // Generador de lista de tickets
  Widget _buildTicketList(List<dynamic> orders, {required bool isActiveTab}) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isActiveTab ? "No tienes reservas pendientes" : "Tu historial está vacío",
          style: TextStyle(color: AppTheme.textBlack.withOpacity(0.5)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final pack = order['packs'] ?? {}; 
        final business = pack['businesses'] ?? {}; 
        DateTime date = order['created_at'] != null ? DateTime.parse(order['created_at']).toLocal() : DateTime.now();
        final String code = order['code'] ?? order['pickup_code'] ?? '---';
        
        final double rawPrice = pack['price'] != null ? double.tryParse(pack['price'].toString()) ?? 0.0 : 0.0;
        final String formattedPrice = "${rawPrice.toStringAsFixed(2)} Bs";

        return TicketCard(
          businessName: business['commercial_name'] ?? 'Tienda Local',
          packTitle: pack['title'] ?? 'Pack Reservado',
          price: formattedPrice,
          orderCode: code,
          date: DateFormat('dd MMM, HH:mm').format(date),
          isActive: isActiveTab, 
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
    // Si está activo usa Verde Mango, si es historial usa Gris Claro
    final Color mainColor = isActive ? AppTheme.primaryGreen : AppTheme.disabledIcon;
    final Color textColor = isActive ? AppTheme.textBlack : AppTheme.disabledIcon;
    
    // El código en Naranja solo si está activo para llamar la atención del vendedor
    final Color codeColor = isActive ? AppTheme.accentOrange : AppTheme.disabledIcon;
    final Color backgroundColor = isActive ? Colors.white : AppTheme.disabledBackground;

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
              // --- MITAD SUPERIOR: DATOS DEL PACK ---
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
                          Text(businessName, style: TextStyle(color: AppTheme.textBlack.withOpacity(0.6), fontSize: 14)),
                          const SizedBox(height: 5),
                          Text(packTitle, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(date, style: TextStyle(color: AppTheme.textBlack.withOpacity(0.5), fontSize: 13)),
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
                        painter: DashedLinePainter(color: AppTheme.textBlack.withOpacity(0.15)),
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
                  color: isActive ? mainColor.withOpacity(0.04) : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      isActive ? "CÓDIGO DE RETIRO" : "CÓDIGO CANJEADO / VENCIDO",
                      style: TextStyle(color: AppTheme.textBlack.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      orderCode,
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 6, 
                        color: codeColor, // Naranja si es válido
                        decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isActive)
                      Text(
                        "Muestra este código en el local para retirar tu pack.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textBlack.withOpacity(0.7), fontSize: 13),
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
    // Agujeros laterales
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