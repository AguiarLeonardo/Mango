class PackModel {
  final String id;          // String (UUID)
  final String businessId;  
  final String title;
  final double price;
  final int quantityAvailable;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final String? imageUrl;
  final String? businessName;

  PackModel({
    required this.id,
    required this.businessId,
    required this.title,
    required this.price,
    required this.quantityAvailable,
    required this.pickupStart,
    required this.pickupEnd,
    this.imageUrl,
    this.businessName,
  });

  factory PackModel.fromJson(Map<String, dynamic> json) {
    return PackModel(
      // Convierte ID a String
      id: json['id']?.toString() ?? '', 
      
      // Convierte BusinessID a String (Aquí estaba el fallo persistente)
      businessId: json['business_id']?.toString() ?? '',
      
      title: json['title'] ?? 'Pack sin nombre',
      
      // Manejo seguro de números
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantityAvailable: (json['quantity_available'] as num?)?.toInt() ?? 0,
      
      // Fechas
      pickupStart: DateTime.tryParse(json['pickup_start'].toString()) ?? DateTime.now(),
      pickupEnd: DateTime.tryParse(json['pickup_end'].toString()) ?? DateTime.now(),
      
      imageUrl: json['image_url'],

      // Nombre del negocio
      businessName: (json['businesses'] != null && json['businesses'] is Map)
          ? json['businesses']['commercial_name']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'title': title,
      'price': price,
      'quantity_available': quantityAvailable,
      'pickup_start': pickupStart.toIso8601String(),
      'pickup_end': pickupEnd.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}