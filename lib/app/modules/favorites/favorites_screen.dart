import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'favorites_controller.dart';
import '../packs/pack_detail_screen.dart';
import '../search/business_detail_screen.dart';
import '../../core/theme/app_theme.dart'; // Importante para la consistencia

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
        backgroundColor: AppTheme.backgroundCream, // Fondo unificado
        appBar: AppBar(
          title: const Text(
            "Mis Favoritos",
            style: TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent, // AppBar limpia
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppTheme.accentOrange, // Naranja de tu marca
            indicatorWeight: 3,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.fastfood_outlined, size: 18), SizedBox(width: 8), Text("Packs")],
              )),
              Tab(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.storefront_outlined, size: 18), SizedBox(width: 8), Text("Negocios")],
              )),
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
      return _buildEmptyState("Aún no tienes packs favoritos", Icons.fastfood_outlined);
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

        return _buildFavoriteCard(
          title: title,
          subtitle: "$price Bs",
          icon: Icons.fastfood,
          iconColor: AppTheme.accentOrange,
          onTap: () {
            if (pack.isNotEmpty) {
              Get.to(() => const PackDetailScreen(), arguments: pack);
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
      return _buildEmptyState("Aún no sigues ningún negocio", Icons.storefront_outlined);
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
          leadingWidget: CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: Text(name[0].toUpperCase(), 
              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
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

  Widget _buildFavoriteCard({
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
    Widget? leadingWidget,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: leadingWidget ?? Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryGreen).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? AppTheme.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.redAccent),
          onPressed: onRemove,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}