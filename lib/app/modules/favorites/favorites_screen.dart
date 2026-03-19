import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'favorites_controller.dart';
import '../packs/pack_detail_screen.dart';
import '../business/business_detail_screen.dart';
import '../../core/theme/app_theme.dart'; 
import '../../data/models/pack_model.dart'; 

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController controller =
        Get.isRegistered<FavoritesController>()
            ? Get.find<FavoritesController>()
            : Get.put(FavoritesController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundCream, 
        appBar: AppBar(
          title: const Text(
            "Mis Favoritos",
            style: TextStyle(
              color: AppTheme.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent, 
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppTheme.accentOrange, 
            indicatorWeight: 3,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood_outlined, size: 18),
                    SizedBox(width: 8),
                    Text("Packs"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 18),
                    SizedBox(width: 8),
                    Text("Negocios"),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          return TabBarView(
            children: [
              _buildPacksTab(controller),
              _buildBusinessesTab(controller),
            ],
          );
        }),
      ),
    );
  }

  // ❤️ SECCIÓN PACKS
  Widget _buildPacksTab(FavoritesController controller) {
    if (controller.favoritePacks.isEmpty) {
      return _buildEmptyState(
        "Aún no tienes packs favoritos",
        Icons.fastfood_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.favoritePacks.length,
      itemBuilder: (context, index) {
        final fav = controller.favoritePacks[index];
        final pack = fav['packs'] ?? {};
        final String packId = fav['pack_id'].toString();
        final title = pack['title'] ?? 'Pack';
        final price = pack['price']?.toString() ?? '0';

        // ✅ NUEVO: Intentamos parsear a PackModel aquí para saber si expiró
        PackModel? packModel;
        bool isExpired = false;
        try {
          if (pack.isNotEmpty) {
            packModel = PackModel.fromJson(pack);
            isExpired = packModel.pickupEnd.isBefore(DateTime.now());
          }
        } catch (e) {
          print("Error convirtiendo PackModel para verificar expiración: $e");
        }

        return _buildFavoriteCard(
          title: title,
          subtitle: isExpired ? "Paquete no disponible" : "$price Bs",
          icon: Icons.fastfood,
          iconColor: isExpired ? Colors.grey : AppTheme.accentOrange,
          isExpired: isExpired, // Pasamos la variable a la tarjeta
          onTap: () {
            if (packModel != null) {
              // ✅ Si expiró, mostramos anuncio y NO vamos al detalle
              if (isExpired) {
                Get.snackbar(
                  "Pack no disponible",
                  "El tiempo de venta para este paquete ha terminado.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey.shade900,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(15),
                  duration: const Duration(seconds: 3),
                );
              } else {
                // Si no expiró, vamos a la pantalla
                Get.to(() => const PackDetailScreen(), arguments: packModel);
              }
            }
          },
          onRemove: () => controller.togglePackFavorite(packId),
        );
      },
    );
  }

  // ❤️ SECCIÓN NEGOCIOS
  Widget _buildBusinessesTab(FavoritesController controller) {
    if (controller.favoriteBusinesses.isEmpty) {
      return _buildEmptyState(
        "Aún no sigues ningún negocio",
        Icons.storefront_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.favoriteBusinesses.length,
      itemBuilder: (context, index) {
        final fav = controller.favoriteBusinesses[index];
        final business = fav['businesses'] ?? {};
        final String businessId = fav['business_id'].toString();
        final name = business['commercial_name'] ?? 'Negocio';
        final category = business['category'] ?? 'General';

        return _buildFavoriteCard(
          title: name,
          subtitle: category,
          isExpired: false, // Los negocios no expiran de esta forma
          leadingWidget: CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            if (business.isNotEmpty) {
              Get.to(() => BusinessDetailScreen(businessData: business));
            }
          },
          onRemove: () => controller.toggleBusinessFavorite(businessId),
        );
      },
    );
  }

  // --- WIDGETS REUTILIZABLES ---

  // ✅ Añadido el parámetro isExpired con valor por defecto false
  Widget _buildFavoriteCard({
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
    Widget? leadingWidget,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    bool isExpired = false, 
  }) {
    // Si está expirado, armamos la tarjeta con filtro y menor opacidad
    Widget cardContent = Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: leadingWidget ??
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryGreen).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppTheme.primaryGreen),
            ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isExpired ? Colors.grey.shade700 : AppTheme.textBlack,
          ),
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(
            color: isExpired ? Colors.red.shade400 : Colors.grey.shade600,
            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal
          )
        ),
        trailing: IconButton(
          icon: Icon(Icons.favorite, color: isExpired ? Colors.grey : Colors.redAccent),
          onPressed: onRemove,
        ),
        onTap: onTap,
      ),
    );

    // Si expiró, envolvemos en ColorFiltered para el tono gris
    if (isExpired) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(
          opacity: 0.6,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}