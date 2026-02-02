import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pack_model.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PackModel pack = Get.arguments;

    return Scaffold(
      backgroundColor: AppColors.darkOlive,
      appBar: AppBar(
        title: const Text('Detalle del Pack', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: AppColors.sageGreen,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(pack.description),
                const SizedBox(height: 16),
                Text('Comercio: ${pack.businessName}'),
                Text('Dirección: ${pack.businessAddress}'),
                Text('Ubicación: ${pack.city}, ${pack.state}'),
                const SizedBox(height: 16),
                Text('Precio: \$${pack.price}',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
