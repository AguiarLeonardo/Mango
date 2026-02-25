import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import 'packs_controller.dart'; // Mantén el import de tu controlador actual
import 'pack_detail_screen.dart';

class VendorPacksScreen extends StatelessWidget {
  final PacksController controller = Get.put(PacksController());

  VendorPacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text("Mis Publicaciones",
            style: TextStyle(
                color: AppTheme.textBlack, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundCream,
        elevation: 0,
        centerTitle: true,
      ),

      // ✅ BOTÓN FLOTANTE: Ahora es el botón principal de acción del negocio
      floatingActionButton: Obx(() => controller.isBusiness.value
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePackModal(context),
              label: const Text("Nuevo Pack",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add_business, color: Colors.white),
              backgroundColor: AppTheme.accentOrange,
            )
          : const SizedBox.shrink()),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        // ✅ PROTECCIÓN: Si por alguna razón un usuario normal entra aquí, le avisamos
        if (!controller.isBusiness.value) {
          return const Center(
            child: Text("Esta pantalla es exclusiva para negocios.",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        // ✅ ESTADO VACÍO EXCLUSIVO PARA NEGOCIOS
        if (controller.packsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 80, color: AppTheme.disabledIcon.withOpacity(0.5)),
                const SizedBox(height: 15),
                const Text("No tienes packs activos",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack)),
                const SizedBox(height: 5),
                const Text("Toca el botón 'Nuevo Pack' para publicar.",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // ✅ CUADRÍCULA DE INVENTARIO DEL NEGOCIO
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.packsList.length,
          itemBuilder: (context, index) {
            final pack = controller.packsList[index];
            return _buildVendorPackCard(pack);
          },
        );
      }),
    );
  }

  // ✅ TARJETA ADAPTADA AL VENDEDOR (Muestra stock restante de forma más clara)
  Widget _buildVendorPackCard(Map<String, dynamic> pack) {
    final String title = pack['title'] ?? 'Pack Sorpresa';
    final String price = pack['price'].toString();
    final String? imageUrl = pack['image_url'];
    final int stock = pack['quantity_available'] ?? 0;

    return GestureDetector(
      // Por ahora los lleva al detalle general, pero en el futuro podrías llevarlos a una pantalla de "Editar Pack"
      onTap: () => Get.to(() => const PackDetailScreen(), arguments: pack),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl != null
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      child: const Center(
                          child: Icon(Icons.fastfood,
                              size: 40, color: AppTheme.primaryGreen)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$$price",
                          style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: stock > 0
                              ? AppTheme.accentOrange.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          stock > 0 ? "$stock stock" : "Agotado",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                stock > 0 ? AppTheme.accentOrange : Colors.red,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ MODAL DE CREACIÓN INTACTO (Solo se mejoró un poco el UI)
  void _showCreatePackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => GetBuilder<PacksController>(
        builder: (_) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 15),
                const Text("Publicar Nuevo Pack",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack)),
                const SizedBox(height: 20),

                // Selector de Imagen
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid)),
                    child: controller.pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                                File(controller.pickedImage!.path),
                                fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 40,
                                  color:
                                      AppTheme.disabledIcon.withOpacity(0.6)),
                              const SizedBox(height: 10),
                              Text("Toca para agregar foto",
                                  style:
                                      TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                    controller: controller.titleController,
                    decoration: _inputDecoration(
                        "Título del Pack (Ej: Sorpresa de Pan)")),
                const SizedBox(height: 10),
                TextField(
                    controller: controller.descController,
                    decoration:
                        _inputDecoration("Descripción breve (Opcional)"),
                    maxLines: 2),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: controller.priceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("Precio Oferta \$"))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: controller.originalPriceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("Precio Real \$"))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: controller.quantityController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Cantidad disponible")),

                const SizedBox(height: 20),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Horario de Retiro",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textBlack))),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() => _timeButton(
                        context,
                        "Desde",
                        controller.pickupStart.value,
                        (time) => controller.setPickupStart(DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            time.hour,
                            time.minute)))),
                    const Text("-",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Obx(() => _timeButton(
                        context,
                        "Hasta",
                        controller.pickupEnd.value,
                        (time) => controller.setPickupEnd(DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            time.hour,
                            time.minute)))),
                  ],
                ),

                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.createPack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("PUBLICAR PACK",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helpers visuales para el formulario
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGreen)),
    );
  }

  Widget _timeButton(BuildContext context, String label, DateTime? value,
      Function(TimeOfDay) onSelected) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (time != null) onSelected(time);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                size: 18, color: AppTheme.accentOrange),
            const SizedBox(width: 8),
            Text(value == null ? label : DateFormat('HH:mm').format(value),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
          ],
        ),
      ),
    );
  }
}
