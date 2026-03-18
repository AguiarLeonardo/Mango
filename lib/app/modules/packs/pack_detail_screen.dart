import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pack_model.dart';
import '../cart/cart_controller.dart';
import '../favorites/favorites_controller.dart';
import 'pack_detail_controller.dart'; 

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  // Función auxiliar para formatear la hora (ej: 18:30)
  String _formatTime(DateTime? dt) {
    if (dt == null) return "--:--";
    // Pasamos a local por si viene en UTC de la base de datos
    final localDt = dt.toLocal();
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final PackModel pack = Get.arguments as PackModel;
    final PackDetailController controller = Get.put(PackDetailController());
    final FavoritesController favController = Get.isRegistered<FavoritesController>()
        ? Get.find<FavoritesController>()
        : Get.put(FavoritesController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchReviews(pack.id);
    });

    const ColorFilter greyscale = ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
        actions: [
          Obx(() {
            if (controller.isOwner.value) return const SizedBox.shrink();
            final isFav = favController.isPackFavorite(pack.id);
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                onPressed: () => favController.togglePackFavorite(pack.id),
              ),
            );
          }),
        ],
      ),
      extendBodyBehindAppBar: true,

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
          child: Obx(() {
            final bool active = controller.isActive.value;

            if (controller.isOwner.value) {
              if (active) {
                return ElevatedButton(
                  onPressed: () => controller.confirmHide(pack.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("OCULTAR PACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              } else {
                return ElevatedButton(
                  onPressed: () => controller.confirmReactivate(pack.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("VOLVER A ACTIVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }
            } else {
              if (active) {
                return ElevatedButton(
                  onPressed: () {
                    final cartController = Get.put(CartController());
                    cartController.addToCart(pack);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("RESERVAR PACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              } else {
                return ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("PACK NO DISPONIBLE", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }
            }
          }),
        ),
      ),

      body: Obx(() {
        final bool active = controller.isActive.value;
        
        return Opacity(
          opacity: active ? 1.0 : 0.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- IMAGEN ---
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: pack.imageUrl == null
                      ? const Icon(Icons.fastfood, size: 80, color: Colors.white)
                      : ColorFiltered(
                          colorFilter: active ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : greyscale,
                          child: Image.network(pack.imageUrl!, fit: BoxFit.cover),
                        ),
                ),

                // --- CONTENIDO ---
                Container(
                  padding: const EdgeInsets.all(24),
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

                      // Negocio y Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pack.businessName ?? 'Negocio no especificado',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          Obx(() {
                            if (controller.isLoadingReviews.value) return const SizedBox.shrink();
                            if (controller.totalReviews.value == 0) return const SizedBox.shrink();
                            return Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                                const SizedBox(width: 4),
                                Text(controller.averageRating.value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            );
                          }),
                        ],
                      ),
                      
                      const Divider(height: 40),

                      // 🕒 NUEVA SECCIÓN: HORARIO DE RECOGIDA
                      const Text("Horario de recogida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: AppTheme.primaryGreen),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hoy de ${_formatTime(pack.pickupStart)} a ${_formatTime(pack.pickupEnd)}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textBlack),
                                ),
                                const Text(
                                  "Presenta tu código al llegar al local",
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 📝 DESCRIPCIÓN REFORZADA
                      const Text("¿Qué incluye este pack?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        (pack.description != null && pack.description!.isNotEmpty)
                            ? pack.description!
                            : "Este establecimiento aún no ha añadido una descripción detallada, ¡pero seguro que te sorprenderá!",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                      ),

                      const SizedBox(height: 25),

                      // Cantidad disponible
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text("Solo quedan ${pack.quantityAvailable} unidades",
                            style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 40),
                      
                      // --- RESEÑAS ---
                      const Text("Reseñas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      Obx(() {
                        if (controller.isLoadingReviews.value) return const Center(child: CircularProgressIndicator());
                        if (controller.reviewsList.isEmpty) {
                          return Text("Sin reseñas todavía.", style: TextStyle(color: Colors.grey.shade500));
                        }
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.reviewsList.length,
                          itemBuilder: (context, index) {
                            final review = controller.reviewsList[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Row(
                                children: List.generate(5, (star) => Icon(
                                  star < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber, size: 16,
                                )),
                              ),
                              subtitle: Text(review['comment'] ?? ''),
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
      }),
    );
  }
}