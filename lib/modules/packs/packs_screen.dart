import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'packs_controller.dart';
import '../../routes/app_routes.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PacksController());

    return Scaffold(
      backgroundColor: AppColors.darkOlive,
      appBar: AppBar(
        title: const Text('Packs Cercanos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.packs.length,
          itemBuilder: (context, index) {
            final pack = controller.packs[index];

            return Card(
              color: AppColors.sageGreen,
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(pack.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(pack.businessName),
                trailing: Text('\$${pack.price}'),
                onTap: () {
                  Get.toNamed(
                    Routes.packDetail,
                    arguments: pack,
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
