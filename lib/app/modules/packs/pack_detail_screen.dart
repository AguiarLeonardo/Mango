import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pack_model.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 RECUPERAMOS EL PACK QUE NOS MANDÓ EL DISCOVER
    // Usamos 'as PackModel' para que Dart sepa exactamente qué tipo de dato es
    final PackModel pack = Get.arguments as PackModel;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Botón de atrás (GetX lo maneja automático si usas Get.back() o el default)
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
      ),

      // Extiende el body detrás del AppBar para que la foto se vea increíble
      extendBodyBehindAppBar: true,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGEN GRANDE ---
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: pack.imageUrl == null
                ? const Icon(Icons.fastfood, size: 80, color: Colors.white)
                : Image.network(pack.imageUrl!, fit: BoxFit.cover),
          ),

          // --- DETALLES DEL PACK ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pack.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "\$${pack.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nombre del negocio
                  Text(
                    pack.businessName ?? 'Negocio no especificado',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 24),

                  // Disponibilidad
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Solo quedan ${pack.quantityAvailable} packs",
                      style: const TextStyle(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ Enviamos el pack completo como argumento a la pasarela de pago
                        Get.toNamed(Routes.payment, arguments: pack);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("RESERVAR PACK",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
