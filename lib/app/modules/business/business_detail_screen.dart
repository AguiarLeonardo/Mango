import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../favorites/favorites_controller.dart';
import '../business/business_controller.dart';
import '../../data/models/pack_model.dart';
// ✅ IMPORTAMOS EL MODELO DEL NEGOCIO
import '../../data/models/business_model.dart';

class BusinessDetailScreen extends StatelessWidget {
  // ✅ 1. CAMBIAMOS A DYNAMIC PARA QUE ACEPTE AMBOS TIPOS (Map o BusinessModel)
  final dynamic businessData;

  const BusinessDetailScreen({
    super.key,
    this.businessData, // Le quitamos el 'required'
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 2. LEEMOS LOS DATOS DE Get.arguments (Si no hay, usa el del constructor)
    final dynamic data = Get.arguments ?? businessData;

    // ✅ 3. IDENTIFICAMOS QUÉ TIPO DE DATO LLEGÓ
    final bool isMap = data is Map;

    // Extraemos la información de forma segura
    final String businessId = isMap 
        ? (data['id']?.toString() ?? '') 
        : (data.id?.toString() ?? '');
        
    final String name = isMap 
        ? (data['commercial_name'] ?? "Comercio") 
        : (data.commercialName ?? "Comercio");
        
    final String address = isMap 
        ? (data['address'] ?? "Dirección no registrada") 
        : (data.address ?? "Dirección no registrada");
        
    final String category = isMap 
        ? (data['category'] ?? "General") 
        : (data.category ?? "General");

    // Inyectamos el controlador específico de este negocio usando un tag
    final controller = Get.put(
      BusinessDetailController(businessId: businessId),
      tag: businessId,
    );

    // Inyección segura FavoritesController
    final FavoritesController favController =
        Get.isRegistered<FavoritesController>()
            ? Get.find<FavoritesController>()
            : Get.put(FavoritesController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() {
            final isFav = favController.isBusinessFavorite(businessId);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : Colors.white,
              ),
              onPressed: () => favController.toggleBusinessFavorite(businessId),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // --- CABECERA ---
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "M",
                    style: const TextStyle(
                      fontSize: 30,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentOrange),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppTheme.disabledIcon),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        address,
                        style: TextStyle(
                            color: AppTheme.textBlack.withOpacity(0.7)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- TÍTULO DE LISTA ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ofertas Disponibles",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBlack.withOpacity(0.9),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- LISTA DE PACKS ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // ✅ AQUÍ ESTÁ LA MAGIA DEL FILTRO: 
              // Descartamos todo lo que esté inactivo, agotado o vencido.
              final ahora = DateTime.now();
              final validPacks = controller.availablePacks.where((packMap) {
                // 1. Validar que esté activo
                final bool isActive = packMap['is_active'] == true || packMap['is_active'] == 1;
                
                // 2. Validar que haya cantidad disponible
                final int quantity = (packMap['quantity_available'] as num?)?.toInt() ?? 0;
                
                // 3. Validar que la hora de fin (pickup_end) no haya pasado
                final String pickupEndStr = packMap['pickup_end']?.toString() ?? '';
                DateTime? pickupEnd;
                if (pickupEndStr.isNotEmpty) {
                  pickupEnd = DateTime.tryParse(pickupEndStr)?.toLocal();
                }
                final bool isNotExpired = pickupEnd != null ? pickupEnd.isAfter(ahora) : false;

                return isActive && quantity > 0 && isNotExpired;
              }).toList();

              // ✅ Validamos contra nuestra NUEVA lista filtrada, no la del controlador crudo
              if (validPacks.isEmpty) {
                return Center(
                  child: Text(
                    "No hay packs disponibles ahora.",
                    style:
                        TextStyle(color: AppTheme.textBlack.withOpacity(0.5)),
                  ),
                );
              }

              return ListView.builder(
                itemCount: validPacks.length, // Usamos los filtrados
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                itemBuilder: (context, index) {
                  final packMap = validPacks[index]; // Extraemos de los filtrados
                  final title = packMap['title'] ?? 'Pack Sorpresa';
                  final price = packMap['price']?.toString() ?? '0';

                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("\$$price",
                          style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppTheme.disabledIcon),
                      onTap: () {
                        // Inyectamos manualmente el nombre del negocio al pack
                        packMap['businesses'] = {'commercial_name': name};
                        final packModel = PackModel.fromJson(packMap);
                        Get.toNamed('/pack-detail', arguments: packModel);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}