import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../packs/vendedor_packs_screen.dart';
import 'business_dashboard_controller.dart';
import 'business_orders_controller.dart';
import 'business_orders_screen.dart';

// ✅ IMPORTACIONES DEL DRAWER (Ajusta las rutas si te marcan error)
import '../support/support_screen.dart';
import '../shell/shell_controller.dart';
import '../../routes/app_routes.dart';

// 👇 NUEVA IMPORTACIÓN PARA EL HISTORIAL 👇
import '../business_history/business_history_screen.dart'; 

class BusinessDashboardScreen extends GetView<BusinessDashboardController> {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controllers if not already available
    Get.put(BusinessOrdersController());
    final vendorPacksScreen = VendorPacksScreen();

    return Obx(() => Scaffold(
          backgroundColor: AppTheme.backgroundCream,

          // ─── DRAWER: MENÚ LATERAL ───
          drawer: _buildDrawer(),

          // ─── APP BAR: PERFIL DEL NEGOCIO ───
          appBar: _buildAppBar(),

          // ─── BODY: INDEXED STACK ───
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              vendorPacksScreen, // Tab 0: Mis Packs
              const BusinessOrdersScreen(), // Tab 1: Entregas / Pedidos
            ],
          ),

          // ─── FAB: CREAR PACK (solo en pestaña Mis Packs) ───
          floatingActionButton: controller.currentIndex.value == 0
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      vendorPacksScreen.openCreatePackModal(context),
                  label: const Text("Nuevo Pack",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  icon: const Icon(Icons.add, color: Colors.white),
                  backgroundColor: AppTheme.accentOrange,
                )
              : null,

          // ─── BOTTOM NAVIGATION BAR ───
          bottomNavigationBar: _buildBottomNavigationBar(),
        ));
  }

  // ==========================================
  // 🍔 WIDGET DEL MENÚ LATERAL (DRAWER)
  // ==========================================
  Drawer _buildDrawer() {
    return Drawer(
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
                      backgroundImage: (controller.businessImageUrl.value != null && 
                                        controller.businessImageUrl.value!.isNotEmpty)
                          ? NetworkImage(controller.businessImageUrl.value!)
                          : null,
                      child: (controller.businessImageUrl.value == null || 
                              controller.businessImageUrl.value!.isEmpty)
                          ? const Icon(
                              Icons.storefront,
                              size: 35,
                              color: AppTheme.primaryGreen,
                            )
                          : null,
                    )),
                const SizedBox(height: 10),
                Obx(() => Text(
                      controller.businessName.value.isNotEmpty
                          ? controller.businessName.value
                          : "Mi Negocio",
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
            leading: const Icon(Icons.person_outline, color: AppTheme.textBlack),
            title: const Text('Mi Perfil'),
            onTap: () async {
              Get.back(); // Cierra el menú
              // Reutilizamos tu lógica de recarga
              await Get.toNamed('/edit-business-profile');
              controller.fetchBusinessProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco_outlined, color: AppTheme.textBlack),
            title: const Text('Mi Impacto'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.impact); 
            },
          ),
          
          // 👇 AQUÍ AGREGAMOS EL BOTÓN DEL HISTORIAL 👇
          ListTile(
            leading: const Icon(Icons.history, color: AppTheme.textBlack),
            title: const Text('Historial de Ventas'),
            onTap: () {
              Get.back(); // Cierra el drawer
              Get.to(() => const BusinessHistoryScreen()); // Navega al historial
            },
          ),
          // 👆 FIN DEL BOTÓN DE HISTORIAL 👆

          ListTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.textBlack),
            title: const Text('Ayuda y Soporte'),
            onTap: () {
              Get.back();
              Get.to(() => const SupportScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppTheme.textBlack),
            title: const Text('Configuración'),
            onTap: () {
              Get.back();
              Get.toNamed('/settings');
            },
          ),
          const Divider(),
          // ✅ AQUI ESTÁ EL BOTÓN DE CERRAR SESIÓN MODIFICADO
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Get.back(); // Cierra el drawer primero
              try {
                // Ejecuta la lógica de limpiar tokens/Firebase
                if (Get.isRegistered<ShellController>()) {
                  await Get.find<ShellController>().signOut();
                }
                // Te manda al login y borra las pantallas anteriores
                Get.offAllNamed('/login'); 
              } catch (e) {
                debugPrint("Error al cerrar sesión: $e");
                // Si algo falla, igual forza la salida al login por seguridad
                Get.offAllNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 📱 APP BAR MODIFICADO
  // ==========================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80, // Aspecto más premium y espacioso
      titleSpacing: 0, // Ajustado a 0 para dar espacio al icono del menú
      
      // ✅ BOTÓN DE HAMBURGUESA PARA ABRIR EL DRAWER
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),

      title: GestureDetector(
        // ✅ AQUÍ ESTÁ LA MAGIA: Agregamos "async" y "await"
        onTap: () async {
          // 1. 🚀 VIAJAMOS A LA PANTALLA DE EDICIÓN Y ESPERAMOS
          await Get.toNamed('/edit-business-profile');
          
          // 2. 🔄 AL REGRESAR, ACTUALIZAMOS LOS DATOS (Para que baje la nueva foto)
          controller.fetchBusinessProfile();
        },
        child: Row(
          children: [
            _buildBusinessAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.businessName.value.isNotEmpty
                        ? controller.businessName.value
                        : 'Mi Negocio',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // ✅ FILA DE CATEGORÍA E IMPACTO
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (controller.businessCategory.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.businessCategory.value.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        
                        // 🌱 MINI-DASHBOARD DE IMPACTO (Aparece si hay al menos 1 pack)
                        if (controller.packsRescued.value > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withAlpha(30), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco, color: Colors.lightGreenAccent, size: 12),
                                const SizedBox(width: 3),
                                Text("${controller.packsRescued.value}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                
                                const SizedBox(width: 6),
                                Container(width: 1, height: 10, color: Colors.white.withAlpha(60)),
                                const SizedBox(width: 6),
                                
                                const Icon(Icons.cloud_done_outlined, color: Colors.white70, size: 12),
                                const SizedBox(width: 3),
                                Text("${controller.co2Avoided.value.toStringAsFixed(1)}kg", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: _buildActionButton(
            icon: Icons.qr_code_scanner_rounded,
            tooltip: 'Validar Entrega',
            onPressed: () => _showValidationDialog(),
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
    );
  }

  Widget _buildBusinessAvatar() {
    final String name = controller.businessName.value;
    final String? imageUrl = controller.businessImageUrl.value;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white.withAlpha(40),
        // ✅ Si hay URL de imagen, la muestra. Si no, muestra la inicial.
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? NetworkImage(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'N',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, height: 1.5),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 12, height: 1.5),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined, size: 26),
                activeIcon: Icon(Icons.inventory_2_rounded, size: 30),
                label: 'Mis Packs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined, size: 26),
                activeIcon: Icon(Icons.local_shipping_rounded, size: 30),
                label: 'Entregas',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Diálogo rápido de validación de entrega ───
  void _showValidationDialog() {
    final TextEditingController codeController = TextEditingController();
    final BusinessOrdersController ordersCtrl =
        Get.find<BusinessOrdersController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner_rounded,
                  size: 50, color: AppTheme.primaryGreen),
              const SizedBox(height: 16),
              const Text(
                "Validar Entrega",
                style: TextStyle(
                  color: AppTheme.textBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Ingresa el código proporcionado por el cliente",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: "Ej. MNG-4X9B",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryGreen, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.tag, color: Colors.grey),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Cancelar",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final code = codeController.text.trim();
                        if (code.isNotEmpty) {
                          Get.back();
                          ordersCtrl.validateOrderCode(code);
                        } else {
                          Get.snackbar(
                            "Error",
                            "Debes ingresar un código válido",
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text("Confirmar",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}