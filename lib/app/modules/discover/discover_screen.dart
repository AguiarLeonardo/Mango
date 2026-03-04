import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../support/support_screen.dart';
import '../../core/theme/app_theme.dart';
import 'discover_controller.dart';
import '../../data/models/pack_model.dart';
import '../../data/models/business_model.dart';
import '../shell/shell_controller.dart';
import '../profile/profile_screen.dart';

// ✅ IMPORTAMOS EL CARRITO Y LAS RUTAS
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DiscoverController controller = Get.put(DiscoverController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        backgroundImage: controller.avatarUrl.value.isNotEmpty
                            ? NetworkImage(controller.avatarUrl.value)
                            : null,
                        child: controller.avatarUrl.value.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 35,
                                color: AppTheme.primaryGreen,
                              )
                            : null,
                      )),
                  const SizedBox(height: 10),
                  Obx(() => Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value
                            : "Usuario",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.person_outline, color: AppTheme.textBlack),
              title: const Text('Mi Perfil'),
              onTap: () {
                Get.back();
                Get.to(() => const ProfileScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppTheme.textBlack),
              title: const Text('Ayuda y Soporte'),
              onTap: () {
                Get.back();
                Get.to(() => const SupportScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: AppTheme.textBlack),
              title: const Text('Configuración'),
              onTap: () {
                Get.back();
                Get.toNamed('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Get.back();
                try {
                  Get.find<ShellController>().signOut();
                } catch (e) {
                  debugPrint("Error al cerrar sesión: $e");
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Builder(builder: (context) {
          return GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: controller.avatarUrl.value.isNotEmpty
                          ? NetworkImage(controller.avatarUrl.value)
                          : null,
                      child: controller.avatarUrl.value.isEmpty
                          ? const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    )),
                const SizedBox(width: 12),
                Obx(() => Text(
                      controller.userName.value.isNotEmpty
                          ? controller.userName.value
                          : "Usuario",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          );
        }),
        // ✅ ICONO DEL CARRITO ACTUALIZADO
        actions: [
          Obx(() {
            final cartController = Get.put(CartController());
            // Ahora revisamos si la lista tiene elementos
            final hasItem = cartController.cartItems.isNotEmpty;

            return IconButton(
              onPressed: () {
                Get.toNamed(Routes.cart);
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: hasItem ? AppTheme.accentOrange : Colors.white,
                    size: 28,
                  ),
                  // Globito rojo con el número de elementos
                  if (hasItem)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '${cartController.cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(width: 15),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.userName.value.isNotEmpty
                            ? "¡Hola, ${controller.userName.value}! 👋"
                            : "¡Hola! 👋",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          text: "Descubre ",
                          style: TextStyle(
                            color: AppTheme.textBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          children: [
                            TextSpan(
                              text: "packs hoy",
                              style: TextStyle(color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Salva comida,",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "ahorra dinero.",
                                style: TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 30,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Packs recomendados",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: controller.featuredPacks.length,
                    itemBuilder: (context, index) {
                      return _buildPackCard(controller.featuredPacks[index]);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Negocios cerca de ti",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: controller.recommendedBusinesses.length,
                    itemBuilder: (context, index) {
                      return _buildBusinessCard(
                          controller.recommendedBusinesses[index]);
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPackCard(PackModel pack) {
    return GestureDetector(
      onTap: () => Get.toNamed('/pack-detail', arguments: pack),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: pack.imageUrl == null
                      ? const Icon(Icons.fastfood,
                          color: Colors.white, size: 50)
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.network(
                            pack.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    pack.businessName ?? "Negocio",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${pack.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${pack.quantityAvailable} disp.",
                        style: const TextStyle(
                          color: AppTheme.accentOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(BusinessModel business) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.businessDetail, arguments: business),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront,
                  color: AppTheme.primaryGreen, size: 25),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    business.commercialName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                  ),
                  Text(
                    business.category ?? "Comida",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          business.city ?? business.address,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}