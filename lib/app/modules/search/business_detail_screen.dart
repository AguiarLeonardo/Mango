import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Map<String, dynamic> businessData;

  const BusinessDetailScreen({super.key, required this.businessData});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    // Datos del negocio
    final String name = businessData['commercial_name'] ?? "Comercio";
    final String address = businessData['address'] ?? "Dirección no registrada";
    final String category = businessData['category'] ?? "General";
    final String businessId = businessData['id']; 

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. CABECERA DEL NEGOCIO ---
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(bottom: BorderSide(color: Colors.green.shade100)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green[200],
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "M",
                    style: TextStyle(fontSize: 30, color: Colors.green[900], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200)
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Colors.orange[800], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        address,
                        style: TextStyle(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Ofertas Disponibles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ),
          ),
          const SizedBox(height: 10),

          // --- 2. LISTA DE PACKS (FutureBuilder) ---
          Expanded(
            child: FutureBuilder(
              future: supabase
                  .from('packs')
                  .select()
                  // CORRECCIÓN 1: Usamos 'business_id' según tu Supabase
                  .eq('business_id', businessId) 
                  // CORRECCIÓN 2: Buscamos 'available' en vez de 'active'
                  .eq('status', 'available'), 
              
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red), 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final packs = snapshot.data as List<dynamic>? ?? [];

                if (packs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_shopping_cart, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("No hay packs disponibles ahora.", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: packs.length,
                  padding: const EdgeInsets.all(15),
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    
                    // Extraemos datos seguros usando los nombres de tu tabla
                    final title = pack['title'] ?? 'Pack Sorpresa';
                    final description = pack['description'] ?? 'Sin descripción';
                    final price = pack['price']?.toString() ?? '0';
                    final originalPrice = pack['original_price']?.toString();

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // Si quisieras usar 'image_url' en el futuro, iría aquí.
                          child: const Icon(Icons.fastfood, color: Colors.orange, size: 30),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "$price Bs",
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (originalPrice != null) ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    "$originalPrice Bs",
                                    style: const TextStyle(
                                      color: Colors.grey, 
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Aquí iría la lógica para reservar
                            Get.snackbar("Detalle", "Has seleccionado $title");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            minimumSize: const Size(60, 36)
                          ),
                          child: const Text("Ver", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}