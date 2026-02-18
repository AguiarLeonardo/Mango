import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'favorites_controller.dart';
import '../packs/pack_detail_screen.dart';
import '../search/business_detail_screen.dart';

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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Mis Favoritos",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            indicatorWeight: 4,
            tabs: [
              Tab(icon: Icon(Icons.fastfood), text: "Packs"),
              Tab(icon: Icon(Icons.storefront), text: "Negocios"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
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

  // ===============================
  // ❤️ PACKS
  // ===============================

  Widget _buildPacksTab(FavoritesController controller) {
    if (controller.favoritePacks.isEmpty) {
      return const Center(
        child: Text(
          "Aún no tienes packs favoritos",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: controller.favoritePacks.length,
      itemBuilder: (context, index) {

        final fav = controller.favoritePacks[index];
        final pack = fav['packs'] ?? {};
        final String packId = fav['pack_id'].toString();

        final title = pack['title'] ?? 'Pack';
        final price = pack['price']?.toString() ?? '0';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.fastfood, color: Colors.white),
            ),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("$price Bs"),
            trailing: IconButton(
              icon: const Icon(Icons.favorite,
                  color: Colors.redAccent),
              onPressed: () =>
                  controller.togglePackFavorite(packId),
            ),
            onTap: () {
              if (pack.isNotEmpty) {
                Get.to(
                  () => const PackDetailScreen(),
                  arguments: pack, // 👈 importante
                );
              }
            },
          ),
        );
      },
    );
  }

  // ===============================
  // ❤️ NEGOCIOS
  // ===============================

  Widget _buildBusinessesTab(FavoritesController controller) {
    if (controller.favoriteBusinesses.isEmpty) {
      return const Center(
        child: Text(
          "Aún no sigues ningún negocio",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: controller.favoriteBusinesses.length,
      itemBuilder: (context, index) {

        final fav = controller.favoriteBusinesses[index];
        final business = fav['businesses'] ?? {};
        final String businessId =
            fav['business_id'].toString();

        final name =
            business['commercial_name'] ?? 'Negocio';
        final category =
            business['category'] ?? 'General';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            subtitle: Text(category),
            trailing: IconButton(
              icon: const Icon(Icons.favorite,
                  color: Colors.redAccent),
              onPressed: () =>
                  controller.toggleBusinessFavorite(
                      businessId),
            ),
            onTap: () {
              if (business.isNotEmpty) {
                Get.to(
                  () => BusinessDetailScreen(
                      businessData: business),
                );
              }
            },
          ),
        );
      },
    );
  }
}
