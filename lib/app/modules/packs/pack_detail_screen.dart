import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pack_model.dart';
import '../cart/cart_controller.dart';
import 'pack_detail_controller.dart'; // ✅ IMPORTAMOS EL NUEVO CONTROLADOR

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PackModel pack = Get.arguments as PackModel;
    
    // ✅ Inyectamos el controlador de reseñas
    final PackDetailController controller = Get.put(PackDetailController());
    
    // ✅ Le decimos al controlador que busque las reseñas de este pack al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchReviews(pack.id);
    });

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
      ),
      extendBodyBehindAppBar: true,

      // ✅ BOTÓN DE RESERVA FIJO ABAJO
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              final cartController = Get.put(CartController());
              cartController.addToCart(pack);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("RESERVAR PACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),

      // ✅ CUERPO DESLIZABLE
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGEN GRANDE ---
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: pack.imageUrl == null
                  ? const Icon(Icons.fastfood, size: 80, color: Colors.white)
                  : Image.network(pack.imageUrl!, fit: BoxFit.cover),
            ),

            // --- DETALLES DEL PACK ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(pack.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        "\$${pack.price.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nombre del negocio Y CALIFICACIÓN PROMEDIO ⭐
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pack.businessName ?? 'Negocio no especificado',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      
                      Obx(() {
                        if (controller.isLoadingReviews.value) {
                          return const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentOrange));
                        }
                        if (controller.totalReviews.value == 0) return const SizedBox.shrink();
                        
                        return Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                            const SizedBox(width: 4),
                            Text(
                              controller.averageRating.value.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              " (${controller.totalReviews.value})",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Disponibilidad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text("Solo quedan ${pack.quantityAvailable} packs",
                        style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 35),
                  
                  // --- SECCIÓN DE RESEÑAS (NUEVO) ---
                  const Text("Reseñas de este pack", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Obx(() {
                    if (controller.isLoadingReviews.value) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
                    }
                    if (controller.reviewsList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text("Aún no hay reseñas. ¡Sé el primero en calificarlo al comprarlo! ⭐",
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      );
                    }

                    // Lista de comentarios
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(), // Evita conflicto de scroll
                      shrinkWrap: true,
                      itemCount: controller.reviewsList.length,
                      itemBuilder: (context, index) {
                        final review = controller.reviewsList[index];
                        final int rating = review['rating'] ?? 5;
                        final String comment = review['comment'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundCream.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              if (comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "\"$comment\"",
                                  style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                ),
                              ]
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}