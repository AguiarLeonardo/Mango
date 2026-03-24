import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../support/support_screen.dart';
import '../../core/theme/app_theme.dart';
import 'discover_controller.dart';
import '../../data/models/pack_model.dart';
import '../../data/models/business_model.dart';
import '../shell/shell_controller.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_controller.dart';
import '../favorites/favorites_controller.dart';
import 'package:intl/intl.dart';

// ✅ IMPORTAMOS EL CARRITO Y LAS RUTAS
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../../core/services/network_service.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DiscoverController controller = Get.put(DiscoverController());
    final FavoritesController favController =
        Get.isRegistered<FavoritesController>()
            ? Get.find<FavoritesController>()
            : Get.put(FavoritesController());

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

            // ✅ AQUÍ ESTÁ LA MAGIA: Lógica para enviar a Empresa o Usuario
            ListTile(
              leading:
                  const Icon(Icons.person_outline, color: AppTheme.textBlack),
              title: const Text('Mi Perfil'),
              onTap: () {
                Get.back(); // Cierra el menú lateral primero

                final shellController = Get.find<ShellController>();

                if (shellController.isBusiness.value) {
                  // Si es una EMPRESA, va a la vista nueva que creamos
                  Get.toNamed('/edit-business-profile');
                } else {
                  // Si es un USUARIO NORMAL, va a la vista original
                  Get.to(() => const ProfileScreen());
                }
              },
            ),

            // ✅ MI BILLETERA
            Obx(() {
              final walletCtrl = Get.find<WalletController>();
              return ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.primaryGreen,
                ),
                title: const Text('Mi Billetera'),
                trailing: walletCtrl.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryGreen,
                        ),
                      )
                    : Text(
                        walletCtrl.formattedBalance,
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.wallet);
                },
              );
            }),

            // 🌿 Historial de Impacto
            ListTile(
              leading: const Icon(Icons.eco, color: AppTheme.primaryGreen),
              title: const Text('Mi Impacto'),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.impact);
              },
            ),

            ListTile(
              leading:
                  const Icon(Icons.help_outline, color: AppTheme.textBlack),
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

      // ✅ APPBAR MODIFICADO SÓLO PARA AGREGAR EL IMPACTO
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight:
            70, // 👈 Le damos un poco más de altura para que quepa el impacto
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
                      radius: 22, // 👈 Ajustado ligeramente
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

                // 👈 COLUMNA QUE CONTIENE EL NOMBRE Y EL IMPACTO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Text(
                            controller.userName.value.isNotEmpty
                                ? controller.userName.value
                                : "Usuario",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),

                      // 🌱 MINI-DASHBOARD DE IMPACTO
                      Obx(() {
                        if (controller.packsRescued.value > 0) {
                          return Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.eco,
                                    color: Colors.lightGreenAccent, size: 10),
                                const SizedBox(width: 3),
                                Text("${controller.packsRescued.value}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                Container(
                                    width: 1,
                                    height: 10,
                                    color: Colors.white.withOpacity(0.6)),
                                const SizedBox(width: 6),
                                const Icon(Icons.cloud_done_outlined,
                                    color: Colors.white70, size: 10),
                                const SizedBox(width: 3),
                                Text(
                                    "${controller.co2Avoided.value.toStringAsFixed(1)}kg",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }
                        return const SizedBox
                            .shrink(); // Si no tiene packs, no muestra nada
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          Obx(() {
            final walletCtrl = Get.find<WalletController>();
            if (walletCtrl.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    walletCtrl.formattedBalance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            final cartController = Get.put(CartController());
            final hasItem = cartController.cartItems.isNotEmpty;

            return IconButton(
              onPressed: () {
                Get.toNamed(Routes.cart);
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: hasItem ? AppTheme.accentOrange : Colors.white,
                    size: 34,
                  ),
                  if (hasItem)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '${cartController.cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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

      // ✅ EL CUERPO (BODY) QUEDA EXACTAMENTE COMO TÚ LO TENÍAS
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
                      Obx(() {
                        final isOnline = Get.find<NetworkService>().isOnline.value;
                        if (isOnline) {
                          return RichText(
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
                          );
                        } else {
                          return const Text(
                            "Sin conexión a internet",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          );
                        }
                      }),
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
                    "Negocios en tu zona",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15),
                Obx(() {
                  if (controller.isLoadingStores.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen),
                      ),
                    );
                  }

                  if (controller.stateStores.isEmpty) {
                    final displayState = controller.userState.value.isNotEmpty
                        ? controller.userState.value
                        : 'tu zona';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Center(
                        child: Text(
                          "No hay locales registrados en $displayState",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: controller.stateStores.length,
                      itemBuilder: (context, index) {
                        return _buildNearbyStoreCard(
                            controller.stateStores[index]);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Packs recomendados",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: controller.featuredPacks.length,
                  itemBuilder: (context, index) {
                    return _buildPackCard(
                        controller.featuredPacks[index], favController);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPackCard(PackModel pack, FavoritesController favController) {
    // ✅ Obtenemos el controlador para saber si es empresa
    final DiscoverController controller = Get.find<DiscoverController>();

    String timeRange;
    try {
      timeRange =
          '${DateFormat('HH:mm').format(pack.pickupStart.toLocal())} - ${DateFormat('HH:mm').format(pack.pickupEnd.toLocal())}';
    } catch (_) {
      timeRange = 'Horario no definido';
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/pack-detail', arguments: pack),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGEN CON BOTÓN DE FAVORITO ---
            SizedBox(
              width: 120,
              height: 130,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16)),
                    ),
                    child: pack.imageUrl == null
                        ? const Center(
                            child: Icon(Icons.fastfood,
                                color: Colors.white, size: 40))
                        : ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16)),
                            child: Image.network(
                              pack.imageUrl!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 130,
                            ),
                          ),
                  ),
                  // ❤️ Botón de favorito — solo para usuarios, NO empresas
                  if (!controller.isBusiness.value)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Obx(() {
                        final isFav = favController.isPackFavorite(pack.id);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 18,
                            padding: const EdgeInsets.all(5),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                            ),
                            onPressed: () =>
                                favController.togglePackFavorite(pack.id),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),

            // --- INFORMACIÓN DEL PACK ---
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pack.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pack.businessName ?? "Negocio",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 📝 Descripción (máximo 1 línea)
                    if (pack.description != null &&
                        pack.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          pack.description!,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // 🕐 Rango de horario
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text(
                          timeRange,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${pack.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyStoreCard(Map<String, dynamic> store) {
    final String name = store['commercial_name'] ?? store['name'] ?? 'Negocio';
    final String category = store['category'] ?? "Comida";
    final String city = store['city'] ?? store['address'] ?? "Ciudad";
    final String state = store['state'] ?? '';

    return GestureDetector(
      onTap: () {
        try {
          final String? logoUrl = store['logo_url'] ?? store['profileUrl'] ?? store['image_url'];
          final business = BusinessModel(
            id: store['id'] ?? '',
            commercialName: name,
            category: category,
            city: store['city'],
            address: store['address'] ?? '',
            logoUrl: logoUrl,
          );
          Get.toNamed(Routes.businessDetail, arguments: business);
        } catch (e) {
          print("Error al navegar al negocio: $e");
        }
      },
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
            Builder(
              builder: (context) {
                final String? logoUrl = store['logo_url'] ?? store['profileUrl'] ?? store['image_url'];

                if (logoUrl != null && logoUrl.isNotEmpty) {
                  return CircleAvatar(
                    radius: 22.5,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    child: ClipOval(
                      child: Image.network(
                        logoUrl,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.storefront, color: AppTheme.primaryGreen, size: 25);
                        },
                      ),
                    ),
                  );
                }

                return CircleAvatar(
                  radius: 22.5,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: const Icon(Icons.storefront, color: AppTheme.primaryGreen, size: 25),
                );
              },
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category,
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
                          state.isNotEmpty ? "$city, $state" : city,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
