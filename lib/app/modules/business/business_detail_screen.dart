import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../favorites/favorites_controller.dart';
import '../business/business_controller.dart';
import '../shell/shell_controller.dart';
import '../../data/models/pack_model.dart';
// ✅ IMPORTAMOS EL MODELO DEL NEGOCIO
import '../../data/models/business_model.dart';
import 'package:intl/intl.dart';

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

    // ✅ Para saber si el usuario actual es un negocio
    final ShellController shellController = Get.find<ShellController>();

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
          // ❤️ Favorito del negocio — solo visible para usuarios, NO para empresas
          Obx(() {
            if (shellController.isBusiness.value) return const SizedBox.shrink();
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

              // 🔍 DEBUG: Packs totales recibidos
              print('📦 [BusinessDetail UI] Packs totales recibidos: ${controller.availablePacks.length}');

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

              // 🔍 DEBUG: Packs que pasaron el filtro
              print('✅ [BusinessDetail UI] Packs que pasaron el filtro: ${validPacks.length}');

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
                itemCount: validPacks.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                itemBuilder: (context, index) {
                  final packMap = validPacks[index];
                  final packModel = PackModel.fromJson({
                    ...packMap,
                    'businesses': {'commercial_name': name},
                  });

                  String timeRange;
                  try {
                    timeRange =
                        '${DateFormat('HH:mm').format(packModel.pickupStart.toLocal())} - ${DateFormat('HH:mm').format(packModel.pickupEnd.toLocal())}';
                  } catch (_) {
                    timeRange = 'Horario no definido';
                  }

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed('/pack-detail', arguments: packModel);
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- IMAGEN CON BOTÓN DE FAVORITO ---
                          SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                packModel.imageUrl != null &&
                                        packModel.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        packModel.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 140,
                                      )
                                    : Container(
                                        color: AppTheme.primaryGreen
                                            .withOpacity(0.1),
                                        child: const Center(
                                          child: Icon(Icons.fastfood,
                                              size: 40,
                                              color: AppTheme.primaryGreen),
                                        ),
                                      ),
                                // ❤️ Botón de favorito — solo visible para usuarios
                                if (!shellController.isBusiness.value)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Obx(() {
                                      final isFav = favController
                                          .isPackFavorite(packModel.id);
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          iconSize: 22,
                                          padding: const EdgeInsets.all(6),
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFav
                                                ? Colors.redAccent
                                                : Colors.white,
                                          ),
                                          onPressed: () => favController
                                              .togglePackFavorite(packModel.id),
                                        ),
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          ),

                          // --- CONTENIDO DE LA TARJETA ---
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título y precio
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        packModel.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "\$${packModel.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                // 📝 Descripción
                                if (packModel.description != null &&
                                    packModel.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      packModel.description!,
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                // 🕐 Horario de recolección
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeRange,
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "${packModel.quantityAvailable} disp.",
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}