import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'business_history_controller.dart';
import '../../core/theme/app_theme.dart'; // Ajusta esta ruta según tu proyecto
import 'package:intl/intl.dart'; // Asegúrate de tener intl en tu pubspec.yaml para las fechas

class BusinessHistoryScreen extends StatelessWidget {
  const BusinessHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el controlador
    final BusinessHistoryController controller = Get.put(BusinessHistoryController());

    return DefaultTabController(
      length: 2, // 👈 Tenemos 2 pestañas
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Historial del Negocio",
            style: TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.textBlack),
          // ✅ AQUÍ ESTÁN LAS PESTAÑAS
          bottom: const TabBar(
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryGreen,
            tabs: [
              Tab(text: "Tickets / Ventas"),
              Tab(text: "Packs Finalizados"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          return TabBarView(
            children: [
              // ----------------------------------------------------------------
              // PESTAÑA 1: TICKETS Y VENTAS INDIVIDUALES
              // ----------------------------------------------------------------
              _buildSalesTicketsTab(controller),

              // ----------------------------------------------------------------
              // PESTAÑA 2: RESUMEN DE PACKS FINALIZADOS
              // ----------------------------------------------------------------
              _buildFinishedPacksTab(controller),
            ],
          );
        }),
      ),
    );
  }

  // --- WIDGET PARA LA LISTA DE VENTAS ---
  Widget _buildSalesTicketsTab(BusinessHistoryController controller) {
    if (controller.salesTickets.isEmpty) {
      return Center(
        child: Text("Aún no tienes ventas registradas.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.salesTickets.length,
      itemBuilder: (context, index) {
        final ticket = controller.salesTickets[index];
        final user = ticket['users'] ?? {};
        final pack = ticket['packs'] ?? {};

        final String userName = "${user['first_name'] ?? 'Usuario'} ${user['last_name'] ?? ''}".trim();
        final String packTitle = pack['title'] ?? 'Pack sin nombre';
        final double price = (pack['price'] as num?)?.toDouble() ?? 0.0;
        
        // Formateamos la fecha de la compra
        final DateTime createdAt = DateTime.tryParse(ticket['created_at'].toString())?.toLocal() ?? DateTime.now();
        final String dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
              backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
              child: user['avatar_url'] == null 
                  ? const Icon(Icons.person, color: AppTheme.primaryGreen) 
                  : null,
            ),
            title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Compró: $packTitle", style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(dateFormatted, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
            trailing: Text(
              "\$${price.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET PARA LA LISTA DE PACKS FINALIZADOS ---
  Widget _buildFinishedPacksTab(BusinessHistoryController controller) {
    if (controller.finishedPacks.isEmpty) {
      return Center(
        child: Text("No tienes packs finalizados aún.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.finishedPacks.length,
      itemBuilder: (context, index) {
        final pack = controller.finishedPacks[index];
        
        // ✅ AQUÍ ESTÁ EL CAMBIO: Ahora usamos quantityTotal de tu modelo
        final int total = pack.quantityTotal; 
        final int vendidos = total - pack.quantityAvailable;

        // Formateamos las fechas de inicio y fin
        final String startTime = DateFormat('hh:mm a').format(pack.pickupStart);
        final String endTime = DateFormat('hh:mm a').format(pack.pickupEnd);
        final String date = DateFormat('dd MMM yyyy').format(pack.pickupStart);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(pack.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text("Horario: $startTime - $endTime", style: TextStyle(color: Colors.grey.shade600)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Vendidos: $vendidos / $total", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      !pack.isActive ? "Ocultado manualmente" : "Expirado/Agotado",
                      style: TextStyle(
                        color: !pack.isActive ? Colors.orange : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}