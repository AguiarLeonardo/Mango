import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../favorites/favorites_controller.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Map<String, dynamic> businessData;

  const BusinessDetailScreen({
    super.key,
    required this.businessData,
  });

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    // 🔥 Inyección segura FavoritesController
    final FavoritesController favController =
        Get.isRegistered<FavoritesController>()
            ? Get.find<FavoritesController>()
            : Get.put(FavoritesController());

    // Datos del negocio
    final String name =
        businessData['commercial_name'] ?? "Comercio";
    final String address =
        businessData['address'] ??
            "Dirección no registrada";
    final String category =
        businessData['category'] ?? "General";
    final String businessId =
        businessData['id'].toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Obx(() {
            final isFav = favController
                .isBusinessFavorite(businessId);

            return IconButton(
              icon: Icon(
                isFav
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: isFav
                    ? Colors.redAccent
                    : Colors.white,
              ),
              onPressed: () => favController
                  .toggleBusinessFavorite(
                      businessId),
            );
          }),
        ],
      ),
      body: Column(
        children: [

          // 🔥 CABECERA
          Container(
            padding:
                const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(
                bottom: BorderSide(
                    color:
                        Colors.green.shade100),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      Colors.green[200],
                  child: Text(
                    name.isNotEmpty
                        ? name[0]
                            .toUpperCase()
                        : "M",
                    style: TextStyle(
                      fontSize: 30,
                      color:
                          Colors.green[900],
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                              horizontal: 10,
                              vertical: 4),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(20),
                    border: Border.all(
                        color: Colors
                            .orange
                            .shade200),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors
                          .orange[800],
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color:
                          Colors.grey[600],
                    ),
                    const SizedBox(
                        width: 4),
                    Flexible(
                      child: Text(
                        address,
                        style: TextStyle(
                            color: Colors
                                .grey[700]),
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding:
                const EdgeInsets.symmetric(
                    horizontal: 20),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                "Ofertas Disponibles",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.grey[800],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 LISTA DE PACKS
          Expanded(
            child: FutureBuilder(
              future: supabase
                  .from('packs')
                  .select()
                  .eq('business_id',
                      businessId)
                  .eq('status',
                      'available'),
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator());
                }

                if (snapshot
                    .hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(20),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style:
                            const TextStyle(
                                color:
                                    Colors.red),
                      ),
                    ),
                  );
                }

                final packs =
                    snapshot.data
                            as List<dynamic>? ??
                        [];

                if (packs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay packs disponibles ahora.",
                      style: TextStyle(
                          color:
                              Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount:
                      packs.length,
                  padding:
                      const EdgeInsets
                          .all(15),
                  itemBuilder:
                      (context, index) {
                    final pack =
                        packs[index];

                    final title =
                        pack['title'] ??
                            'Pack Sorpresa';
                    final price =
                        pack['price']
                                ?.toString() ??
                            '0';

                    return Card(
                      margin:
                          const EdgeInsets
                              .only(
                                  bottom:
                                      15),
                      child: ListTile(
                        title:
                            Text(title),
                        subtitle:
                            Text(
                                "$price Bs"),
                        trailing:
                            const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size:
                                    16),
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
