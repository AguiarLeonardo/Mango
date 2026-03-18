import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../impact/impact_controller..dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImpactController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text(
          "Mi Impacto",
          style: TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryGreen),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        final packsCount = controller.packsRescued.value;
        final co2 = controller.co2Avoided.value;
        final money = controller.moneySaved.value;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public, size: 90, color: AppTheme.primaryGreen),
                const SizedBox(height: 15),
                const Text(
                  "Tu Huella Ecológica",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
                const SizedBox(height: 30),

                if (packsCount == 0) ...[
                  Text(
                    "Aún no tienes historial.\n¡Anímate a salvar tu primer pack de comida y ayuda al planeta! 🌱",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textBlack.withOpacity(0.6), fontSize: 16, height: 1.5),
                  )
                ] else ...[
                  // 📦 TARJETA PRINCIPAL: COMIDAS SALVADAS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "${controller.savedMeals.value}",
                              style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 60, height: 1.0, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 40),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Comidas Salvadas",
                          style: TextStyle(color: AppTheme.textBlack, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // 🌿💰 TARJETAS SECUNDARIAS: CO2 y AHORRO
                  Row(
                    children: [
                      // Tarjeta CO2
                      Expanded(
                        child: _buildSmallCard(
                          icon: Icons.cloud_done_outlined,
                          title: "CO2 Evitado",
                          value: "${co2.toStringAsFixed(1)} kg",
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Tarjeta Dinero Ahorrado
                      Expanded(
                        child: _buildSmallCard(
                          icon: Icons.savings_outlined,
                          title: "Ahorro",
                          value: "\$${money.toStringAsFixed(2)}",
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text(
                        "¡Gracias por ser un héroe para el planeta!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.primaryGreen, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // WIDGET REUTILIZABLE PARA LAS TARJETAS PEQUEÑAS
  Widget _buildSmallCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 35, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textBlack, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}