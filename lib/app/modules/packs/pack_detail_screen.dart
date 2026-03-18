import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pack_model.dart';
import '../cart/cart_controller.dart';
import '../favorites/favorites_controller.dart';
import 'pack_detail_controller.dart'; 

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PackModel pack = Get.arguments as PackModel;
    
    // Inyectamos el controlador (que ahora tiene las variables reactivas)
    final PackDetailController controller = Get.put(PackDetailController());
    final FavoritesController favController = Get.isRegistered<FavoritesController>()
        ? Get.find<FavoritesController>()
        : Get.put(FavoritesController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchReviews(pack.id);
    });

    // ✅ Definimos el filtro para poner la imagen en escala de grises
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
          // ❤️ Botón de favorito — solo visible para usuarios, NO para empresas
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

      // ✅ BOTONERA INFERIOR TOTALMENTE DINÁMICA
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
            // Obtenemos el estado actual de forma reactiva
            final bool active = controller.isActive.value;

            // --- CASO 1: ES EL DUEÑO DE LA EMPRESA ---
            if (controller.isOwner.value) {
              // Si está activo, mostramos botón NARANJA de ocultar
              if (active) {
                return ElevatedButton(
                  onPressed: () => controller.confirmHide(pack.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("OCULTAR PACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              } 
              // Si está inactivo, mostramos botón VERDE de volver a activar
              else {
                return ElevatedButton(
                  onPressed: () => controller.confirmReactivate(pack.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("VOLVER A ACTIVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }
            } 
            // --- CASO 2: ES UN USUARIO NORMAL ---
            else {
              // Si está activo, mostramos botón VERDE de reservar normal
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
              } 
              // Si está inactivo, deshabilitamos el botón y cambiamos texto
              else {
                return ElevatedButton(
                  onPressed: null, // ✅ null deshabilita el botón automáticamente
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

      // ✅ CUERPO DE LA PANTALLA ENVUELTO EN OBX PARA REACCIONAR A CAMBIOS
      body: Obx(() {
        final bool active = controller.isActive.value;
        
        // Usamos Opacity para "apagar" un poco toda la pantalla si está inactivo
        return Opacity(
          opacity: active ? 1.0 : 0.5, // 👈 50% de opacidad si está inactivo
          child: SingleChildScrollView(
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
                      // ✅ Aplicamos el filtro de escala de grises dinámicamente
                      : ColorFiltered(
                          colorFilter: active ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) : greyscale,
                          child: Image.network(pack.imageUrl!, fit: BoxFit.cover),
                        ),
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
                      const SizedBox(height: 16),

                      // 📝 Descripción del pack
                      if (pack.description != null && pack.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            pack.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Disponibilidad
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text("Solo quedan ${pack.quantityAvailable} packs",
                            style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 35),
                      
                      // --- SECCIÓN DE RESEÑAS ---
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
      }),
    );
  }
}