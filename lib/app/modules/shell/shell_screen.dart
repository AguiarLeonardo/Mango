import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'shell_controller.dart';

// 🔹 IMPORTS DE TUS PÁGINAS (Sin el perfil)
import '../discover/discover_screen.dart';
import '../search/search_screen.dart';
import '../orders/orders_screen.dart';
import '../favorites/favorites_screen.dart';

class ShellScreen extends StatelessWidget {
  ShellScreen({super.key});

  // ✅ Inyectado via ShellBinding — no usar Get.put aquí
  final ShellController controller = Get.find<ShellController>();

  // 🔹 LISTA DE PÁGINAS (Reducida a 4)
  final List<Widget> pages = [
    const DiscoverScreen(), // Index 0: Inicio
    const SearchScreen(), // Index 1: Buscar
    OrdersScreen(), // Index 2: Reservas
    const FavoritesScreen(), // Index 3: Favoritos
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        // 🔹 CUERPO PRINCIPAL
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),

        // 🔹 BARRA DE NAVEGACIÓN INFERIOR (Solo 4 ítems)
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Descubrir',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Reservas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }
}
