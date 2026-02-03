import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  final List<Widget> pages = [
    const DiscoverView(),
    const BrowseView(),
    const FavoritesView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed, // Siempre muestra las etiquetas
          showUnselectedLabels: true,          // Etiquetas visibles aunque no esté seleccionado
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Descubre',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Explora',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// Vistas placeholder. Luego puedes mover cada una a su archivo independiente.
class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Descubre Packs Cercanos'));
  }
}

class BrowseView extends StatelessWidget {
  const BrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Explora por categoría o mapa'));
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tus packs guardados'));
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tu perfil de usuario'));
  }
}
